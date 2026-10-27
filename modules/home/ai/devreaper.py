"""Reap idle dev servers that agents start and never stop.

A dev-server tree (vite, process-compose stack, standalone postgres, ...) is
"in use" while something *outside* the tree holds a TCP connection to one of
its listening ports (browser HMR websocket, curl, test runner, a device over
the tailnet), or, for a standalone postgres, while it has client backends.
Connections internal to the tree (a BFF pooling into its own postgres) don't
count. Once a tree has been idle for DEVREAPER_IDLE_MIN minutes it is stopped.

Orphaned headless chromiums (parent gone) are killed after
DEVREAPER_ORPHAN_MIN minutes. Any process tree whose root has
DEVREAPER_KEEP=1 in its environment is left alone.
"""

import json
import os
import re
import signal
import sys
import time

IDLE = float(os.environ.get("DEVREAPER_IDLE_MIN", "30")) * 60
ORPHAN = float(os.environ.get("DEVREAPER_ORPHAN_MIN", "15")) * 60
DRY = "--dry-run" in sys.argv
STATE = os.path.join(
    os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")),
    "devreaper.json",
)
UID = os.getuid()
CLK = os.sysconf("SC_CLK_TCK")

JS_TOOLS = {"vite", "next", "astro", "storybook", "wrangler", "tsx", "nodemon"}
JS_RUNTIMES = {"node", "bun", "deno"}
BROWSERS = {"chromium", "chrome", "chromium-browser", "google-chrome", "headless_shell"}


def js_tool(argv):
    """(tool, args) for a JS CLI, whether run directly or as `node .../bin/x.js`."""
    exe = os.path.basename(argv[0])
    if exe in JS_TOOLS:
        return exe, argv[1:]
    if exe not in JS_RUNTIMES:
        return None, []
    for i, a in enumerate(argv[1:], 1):
        if a.startswith("-"):
            continue
        name = re.sub(r"\.[cm]?js$", "", os.path.basename(a))
        if name not in JS_TOOLS:
            pkg = re.findall(r"node_modules/(?:\.pnpm/)?([^/@]+)", a)
            name = pkg[-1] if pkg else name
        return name, argv[i + 1:]
    return None, []


def server_kind(argv):
    """Classify by executable + arguments, never by free text: a shell whose
    `-c` string merely mentions `vite --port` must not count as a server."""
    exe = os.path.basename(argv[0])
    if exe == "postgres" and "-D" in argv:
        return "postgres"
    if exe == "process-compose" and (len(argv) == 1 or argv[1] == "up" or argv[1].startswith("-")):
        return "process-compose"
    if exe.startswith("python") and argv[1:3] == ["-m", "http.server"]:
        return "http.server"
    tool, args = js_tool(argv)
    sub = args[0] if args and not args[0].startswith("-") else None
    if tool == "vite" and sub in (None, "dev", "serve", "preview"):
        return "vite"
    if tool in ("next", "astro", "storybook", "wrangler") and sub == "dev":
        return tool
    if (tool == "tsx" and sub == "watch") or tool == "nodemon":
        return tool
    return None


def is_headless_browser(argv):
    return (
        os.path.basename(argv[0]) in BROWSERS
        and "--headless" in argv
        and not any(a.startswith("--type=") for a in argv)
    )


def boot_time():
    with open("/proc/stat") as f:
        for line in f:
            if line.startswith("btime "):
                return int(line.split()[1])
    return 0


def read_procs():
    procs = {}
    for d in os.listdir("/proc"):
        if not d.isdigit():
            continue
        pid = int(d)
        try:
            if os.stat(f"/proc/{pid}").st_uid != UID:
                continue
            with open(f"/proc/{pid}/cmdline", "rb") as f:
                raw = f.read().rstrip(b"\0")
            argv = raw.decode(errors="replace").split("\0") if raw else []
            with open(f"/proc/{pid}/stat") as f:
                stat = f.read().rsplit(")", 1)[1].split()
        except OSError:
            continue
        if argv:
            procs[pid] = {
                "ppid": int(stat[1]),
                "start": int(stat[19]),
                "argv": argv,
                "kind": server_kind(argv),
            }
    return procs


def socket_owners(pids):
    owners = {}
    for pid in pids:
        try:
            fds = os.listdir(f"/proc/{pid}/fd")
        except OSError:
            continue
        for fd in fds:
            try:
                link = os.readlink(f"/proc/{pid}/fd/{fd}")
            except OSError:
                continue
            if link.startswith("socket:["):
                owners[link[8:-1]] = pid
    return owners


def read_tcp():
    """Yield (local, remote, state, inode); addresses stay as kernel hex."""
    for path in ("/proc/net/tcp", "/proc/net/tcp6"):
        try:
            with open(path) as f:
                next(f)
                for line in f:
                    p = line.split()
                    yield p[1], p[2], p[3], p[9]
        except OSError:
            continue


def port(addr):
    return int(addr.rsplit(":", 1)[1], 16)


def descendants(root, children):
    out, stack = set(), [root]
    while stack:
        pid = stack.pop()
        out.add(pid)
        stack.extend(children.get(pid, ()))
    return out


def keep(pid):
    try:
        with open(f"/proc/{pid}/environ", "rb") as f:
            return b"DEVREAPER_KEEP=1\0" in f.read()
    except OSError:
        return False


def kill_tree(tree, procs, why):
    root = min(tree, key=lambda p: procs[p]["start"])
    print(f"reap pid={root} ({why}): {' '.join(procs[root]['argv'])[:160]}", flush=True)
    if DRY:
        return
    for pid in tree:
        sig = signal.SIGINT if procs[pid]["kind"] == "postgres" else signal.SIGTERM
        try:
            os.kill(pid, sig)
        except OSError:
            pass
    time.sleep(10)
    for pid in tree:
        try:
            os.kill(pid, signal.SIGKILL)
        except OSError:
            pass


def main():
    now = time.time()
    btime = boot_time()
    procs = read_procs()
    children = {}
    for pid, p in procs.items():
        children.setdefault(p["ppid"], []).append(pid)

    def is_server(pid):
        return procs[pid]["kind"] is not None

    def age(pid):
        return now - (btime + procs[pid]["start"] / CLK)

    def has_server_ancestor(pid):
        pid = procs[pid]["ppid"]
        while pid in procs:
            if is_server(pid):
                return True
            pid = procs[pid]["ppid"]
        return False

    roots = [p for p in procs if is_server(p) and not has_server_ancestor(p)]

    owners = socket_owners(procs)
    sockets = list(read_tcp())
    by_pair = {(lo, rem): ino for lo, rem, st, ino in sockets if st == "01"}

    try:
        with open(STATE) as f:
            state = json.load(f)
    except (OSError, ValueError):
        state = {}
    seen = {}

    for root in roots:
        if keep(root):
            continue
        tree = descendants(root, children)
        listen = {port(lo) for lo, _, st, ino in sockets if st == "0A" and owners.get(ino) in tree}
        active = False
        for lo, rem, st, ino in sockets:
            if st != "01" or owners.get(ino) not in tree or port(lo) not in listen:
                continue
            peer = owners.get(by_pair.get((rem, lo)))
            if peer not in tree:
                active = True
                break
        if not active and procs[root]["kind"] == "postgres":
            # Client backends retitle themselves "postgres: user db host ..."
            # (covers unix-socket clients the TCP check can't see).
            active = any(
                re.match(r"postgres: \S+ \S+ ", " ".join(procs[c]["argv"]))
                for c in children.get(root, ())
            )

        key = f"{root}:{procs[root]['start']}"
        last = now if active else state.get(key, now)
        seen[key] = last
        if now - last >= IDLE and age(root) >= IDLE:
            kill_tree(tree, procs, f"idle {int((now - last) / 60)}m")
            seen.pop(key)

    for pid, p in procs.items():
        if is_headless_browser(p["argv"]):
            parent = procs.get(p["ppid"])
            user_manager = parent and parent["argv"][0].endswith("/systemd") and "--user" in parent["argv"]
            orphan = p["ppid"] == 1 or user_manager
            if orphan and age(pid) >= ORPHAN and not keep(pid):
                kill_tree(descendants(pid, children), procs, "orphaned headless browser")

    if not DRY:
        os.makedirs(os.path.dirname(STATE), exist_ok=True)
        with open(STATE, "w") as f:
            json.dump(seen, f)


main()
