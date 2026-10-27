{ pkgs, config, ... }:
let
  # t3 installs itself under ~/.t3/runtime/versions/<version>/ (and
  # `t3 update` adds new ones); run the newest complete install.
  t3 = pkgs.writeShellScriptBin "t3" ''
    for dir in $(ls -d "$HOME"/.t3/runtime/versions/*/ 2>/dev/null | sort -rV); do
      if [ -f "$dir/.install-complete" ] && [ -x "$dir/t3" ]; then
        exec "$dir/t3" "$@"
      fi
    done
    echo "t3: no installed runtime under ~/.t3/runtime/versions" >&2
    exit 1
  '';
in
{
  imports = [
    ../../modules/home
  ];

  ai = {
    agents.enable = true;
    pi.enable = true;
    herdr.enable = true;
    moshi.enable = true;
    executor.enable = true;
    devreaper.enable = true;
  };

  home.packages = with pkgs; [
    kicad

    jetbrains-toolbox
    jetbrains.idea

    t3

    # Rebuild T3's Android SDK from TRIO's current `devShells.android`, then
    # restart t3 so it relinks ~/.t3/android/sdk.
    (writeShellScriptBin "t3-android-sdk-update" ''
      set -eu
      shell=$(nix eval --raw "''${TRIO:-$HOME/Projects/TRIO}#devShells.x86_64-linux.android.drvPath")
      sdk=$(nix-store -q --references "$shell" | grep -- '-androidsdk\.drv$')
      mkdir -p "$HOME/.t3/android"
      NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE=1 nix build "$sdk^out" -o "$HOME/.t3/android/sdk-store"
      systemctl --user restart t3code.service
    '')
  ];

  # T3 Code server, owned here rather than by `t3 service install` (same
  # unit it renders) so it survives a lost ~/.config and is reproducible.
  # ExecStart goes through the `t3` wrapper, so `t3 update` needs no unit
  # rewrite; it rewrites this file anyway (rename over the symlink), so
  # `force` takes it back on the next activation.
  systemd.user.services.t3code = {
    Unit = {
      Description = "T3 Code server";
      StartLimitIntervalSec = 300;
      StartLimitBurst = 5;
    };
    Service = {
      Type = "simple";
      WorkingDirectory = "%h";
      Environment = [
        "T3CODE_HOME=${config.home.homeDirectory}/.t3"
        "T3_BOOT_SERVICE_UNIT=t3code.service"
      ];
      ExecStart = "${t3}/bin/t3 __service-launcher";
      KillMode = "mixed";
      OOMPolicy = "continue";
      Restart = "always";
      RestartSec = 5;
      CPUWeight = 1000;
      IOWeight = 1000;
      ManagedOOMPreference = "avoid";
      StandardOutput = "append:%h/.t3/userdata/logs/boot-service.log";
      StandardError = "append:%h/.t3/userdata/logs/boot-service.log";
    };
    Install.WantedBy = [ "default.target" ];
  };
  xdg.configFile."systemd/user/t3code.service".force = true;
  # `t3 service install`/`t3 update` also re-enable it via systemctl.
  xdg.configFile."systemd/user/default.target.wants/t3code.service".force = true;

  # Drop-ins: pin the port the desktop app pairs with and publish it on the
  # tailnet. The app connects to https://triton.tail43612.ts.net:3773
  # directly, not via SSH-launch, which spawns a second server against the
  # same SQLite state.
  xdg.configFile."systemd/user/t3code.service.d/port.conf".text = ''
    [Service]
    Environment=T3CODE_PORT=3773
    Environment=T3CODE_HOST=127.0.0.1
    ExecStartPost=-${pkgs.tailscale}/bin/tailscale serve --bg --yes --https=3773 http://127.0.0.1:3773
  '';

  # t3 opens SQLite at the default synchronous=FULL, fsyncing the WAL on every
  # commit from its main thread, so one slow fsync freezes the whole server
  # (pingdotgg/t3code#15707, #14701). Until upstream sets it, swap the
  # journal_size_limit pragma for synchronous=NORMAL (same byte length; WAL
  # mode stays crash-safe, a power cut can only drop the last commits). Runs
  # before every start, so versions installed by `t3 update` get patched too;
  # once the upstream code changes the needle stops matching and this no-ops.
  xdg.configFile."systemd/user/t3code.service.d/sqlite-sync.conf".text =
    let
      patch = pkgs.writers.writePython3 "t3-sqlite-sync-patch" { flakeIgnore = [ "E501" ]; } ''
        import glob
        import os
        import subprocess

        OLD = b"sql.unsafe(`PRAGMA journal_size_limit = ''${WAL_SIZE_LIMIT_BYTES};`)"
        NEW = b"sql.unsafe(`PRAGMA synchronous = NORMAL;"
        NEW = NEW + b" " * (len(OLD) - len(NEW) - 2) + b"`)"
        assert len(NEW) == len(OLD)

        for exe in glob.glob(os.path.expanduser("~/.t3/runtime/versions/*/t3")):
            with open(exe, "rb") as f:
                data = f.read()
            if data.count(OLD) != 1:
                continue
            tmp = exe + ".sqlite-sync"
            with open(tmp, "wb") as f:
                f.write(data.replace(OLD, NEW))
            os.chmod(tmp, os.stat(exe).st_mode)
            # It loads modules from its version dir, so test it in place.
            if subprocess.run([tmp, "--version"], capture_output=True).returncode == 0:
                os.replace(tmp, exe)
                print(f"patched {exe}")
            else:
                os.unlink(tmp)
                print(f"patched {exe} failed --version, left unpatched")
      '';
    in
    ''
      [Service]
      ExecStartPre=-${patch}
    '';

  # Device panel / agent emulators. The SDK is TRIO's `devShells.android`
  # androidenv composition (same emulator and images as the Android projects),
  # GC-rooted at ~/.t3/android/sdk-store by `t3-android-sdk-update`. T3 wants
  # cmdline-tools/latest/bin/avdmanager, but androidenv installs a versioned
  # cmdline-tools/<n>, so ANDROID_HOME is a symlink tree adding `latest`.
  xdg.configFile."systemd/user/t3code.service.d/android.conf".text =
    let
      sdkTree = pkgs.writeShellScript "t3-android-sdk-tree" ''
        set -eu
        src="$HOME/.t3/android/sdk-store/libexec/android-sdk"
        dst="$HOME/.t3/android/sdk"
        [ -d "$src" ] || exit 0
        tmp="$dst.tmp"
        rm -rf "$tmp"
        mkdir -p "$tmp/cmdline-tools"
        for entry in "$src"/*; do
          [ "$(basename "$entry")" = cmdline-tools ] || ln -s "$entry" "$tmp/"
        done
        for tools in "$src"/cmdline-tools/*; do
          ln -s "$tools" "$tmp/cmdline-tools/"
        done
        newest=$(ls "$src/cmdline-tools" | sort -V | tail -n 1)
        ln -s "$src/cmdline-tools/$newest" "$tmp/cmdline-tools/latest"
        rm -rf "$dst"
        mv "$tmp" "$dst"
      '';
    in
    ''
      [Service]
      Environment=ANDROID_HOME=%h/.t3/android/sdk
      ExecStartPre=-${sdkTree}
    '';

  xdg.configFile."emacs/init.el".source = ./init.el;
  programs.emacs.enable = false;

  # Host-specific Hyprland facts, loaded by the shared config.lua via `require("host")`.
  xdg.configFile."hypr/host.lua".text = ''
    hl.monitor({
      output = "DP-3",
      mode = "5120x1440@240",
      position = "auto",
      scale = 1,
      cm = "wide",
      vrr = 0,
      bitdepth = 10,
    })

    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
    hl.env("NVD_BACKEND", "direct")

    hl.on("hyprland.start", function()
      hl.exec_cmd("pkill swaybg; swaybg --image ${./wallpaper.jpg}")
    end)
  '';

  home.stateVersion = "25.05";
}
