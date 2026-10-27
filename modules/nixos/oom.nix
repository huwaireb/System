# Proactive OOM avoidance.
#
# The kernel OOM killer is *reactive*: it fires at the last instant, after swap
# is exhausted and the machine has already swap-thrashed into unresponsiveness.
# On a desktop with a 64 GiB swapfile that's a real risk — lots of swap capacity
# just means a longer, more painful death spiral before the killer finally acts.
#
# Layers (cheap → thorough):
#   1. systemd-oomd — cgroup/PSI + global swap cap for system services
#   2. earlyoom     — process-level killer (the single worst offender)
#   3. zram         — compressed in-RAM swap so swapping is fast, not a spiral
#   4. vm.* sysctls — gentler reclaim, fewer latency spikes
{
  config,
  pkgs,
  lib,
  ...
}:
{
  # --- 1. systemd-oomd (cgroup/PSI + global swap cap) ------------------------
  #
  # `enableUserSlices` is deliberately left OFF: it would set
  # `ManagedOOMMemoryPressure=kill` on `user@.slice`, so a pressure spike in the
  # desktop session would make oomd kill the *entire* login session (log you
  # out, taking every app with it). For a single-user desktop that's worse than
  # losing one app — user-app protection lives in earlyoom below instead.
  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableSystemSlice = true;
    settings.OOM = {
      SwapUsedLimit = "90%"; # act once swap is 90% full
      DefaultMemoryPressureLimit = "60%"; # PSI pressure trigger for managed slices
      DefaultMemoryPressureDurationSec = "20s";
    };
  };

  # --- 2. earlyoom (process-level safety net for user apps) ------------------
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # kick in at 5% free RAM, before thrash begins
    freeSwapThreshold = 5; # ...or 5% free swap
  };

  # --- 2b. never kill the t3 code server ------------------------------------
  #
  # `t3 serve` hosts every agent session; losing it drops them all. It's
  # launched outside systemd, so pin it to oom_score_adj=-1000 (skipped by both
  # the kernel OOM killer and earlyoom). Children fork with the inherited value,
  # so reset them to 0 — the agents it spawns must stay killable.
  systemd.services.t3-oom-protect = {
    description = "Exempt the t3 code server from OOM killing";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "always";
      ExecStart = pkgs.writers.writePython3 "t3-oom-protect" { flakeIgnore = [ "E501" ]; } ''
        import fnmatch
        import os
        import time

        T3 = "*/.t3/runtime/versions/*/t3"


        def procs():
            for d in os.listdir("/proc"):
                if not d.isdigit():
                    continue
                try:
                    with open(f"/proc/{d}/cmdline", "rb") as f:
                        argv = f.read().split(b"\0")
                    with open(f"/proc/{d}/stat") as f:
                        ppid = int(f.read().rsplit(")", 1)[1].split()[1])
                    with open(f"/proc/{d}/oom_score_adj") as f:
                        adj = int(f.read())
                except (OSError, ValueError, IndexError):
                    continue
                yield int(d), ppid, adj, [a.decode(errors="replace") for a in argv]


        def set_adj(pid, value):
            try:
                with open(f"/proc/{pid}/oom_score_adj", "w") as f:
                    f.write(str(value))
            except OSError:
                pass


        while True:
            table = {pid: (ppid, adj, argv) for pid, ppid, adj, argv in procs()}
            servers = {
                pid for pid, (_, _, argv) in table.items()
                if len(argv) > 1 and fnmatch.fnmatch(argv[0], T3) and argv[1] == "serve"
            }
            for pid, (ppid, adj, _) in table.items():
                if pid in servers:
                    if adj != -1000:
                        set_adj(pid, -1000)
                    continue
                if adj != -1000:
                    continue
                seen = set()
                while ppid > 1 and ppid not in seen:
                    if ppid in servers:
                        set_adj(pid, 0)
                        break
                    seen.add(ppid)
                    ppid = table.get(ppid, (0,))[0]
            time.sleep(5)
      '';
    };
  };

  # systemd-oomd's root-slice swap kill picks a whole cgroup — t3 lives in the
  # login session scope, and killing that logs you out anyway. Session scopes
  # are root-owned, so the preference is honoured.
  systemd.units."session-.scope" = {
    overrideStrategy = "asDropin";
    text = ''
      [Scope]
      ManagedOOMPreference=omit
    '';
  };

  # --- 3. zram compressed swap -----------------------------------------------
  zramSwap = {
    enable = true;
    memoryPercent = 50; # zram device sized to 50% of RAM
    algorithm = "zstd";
    priority = 100; # prefer fast zram over the disk swapfile/partition
  };

  # --- 4. gentler reclaim ------------------------------------------------------
  boot.kernel.sysctl = {
    "vm.swappiness" = 30; # bias toward RAM before swapping out
    "vm.watermark_scale_factor" = 100; # reclaim earlier/smoother, fewer stalls

    # Cap dirty page cache in bytes. The ratio defaults (10%/20%) let ~6-12 GiB
    # of dirty data build up on a 64 GiB box and flush in bursts; any fsync
    # landing behind a burst (t3's SQLite commits on every agent event, on
    # its main thread) waits seconds. Bulk writers get throttled instead.
    "vm.dirty_background_bytes" = 256 * 1024 * 1024;
    "vm.dirty_bytes" = 1024 * 1024 * 1024;
  };
}
