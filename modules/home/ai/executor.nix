{
  self,
  pkgs,
  lib,
  config,
  osConfig ? { },
  ...
}:
let
  cfg = config.ai;
  executor = self.packages.${pkgs.stdenv.hostPlatform.system}.executor;
  port = toString cfg.executor.port;
  serveCfg = cfg.executor.tailscaleServe;
  httpsPort = toString serveCfg.httpsPort;
  hostName = osConfig.networking.hostName or null;
  tailnetOrigin =
    if hostName == null then
      null
    else if serveCfg.httpsPort == 443 then
      "https://${hostName}.${serveCfg.domain}"
    else
      "https://${hostName}.${serveCfg.domain}:${httpsPort}";
  extraArgs = lib.optionals (serveCfg.enable && tailnetOrigin != null) [
    "--allowed-host"
    tailnetOrigin
  ];

  dataDir = "${config.home.homeDirectory}/.executor";
  chromeProfile = "${dataDir}/chrome-profile";
  chromeCdpPort = "9223";
  mcpJs = "${dataDir}/mcp/node_modules/chrome-devtools-mcp/build/src/bin/chrome-devtools-mcp.js";
  mcpWrapperPath = "${dataDir}/mcp/chrome-devtools-mcp";

  # Session/GPU vars inherited from the graphical login stall navigations
  # (D-Bus + NVIDIA) or make Chromium pick a display instead of headless ozone.
  graphicalUnset = lib.concatStringsSep " " [
    "DISPLAY"
    "WAYLAND_DISPLAY"
    "XDG_SESSION_TYPE"
    "XDG_CURRENT_DESKTOP"
    "DESKTOP_SESSION"
    "GDK_BACKEND"
    "QT_QPA_PLATFORM"
    "SDL_VIDEODRIVER"
    "CLUTTER_BACKEND"
    "NVIDIA_VISIBLE_DEVICES"
    "NVIDIA_DRIVER_CAPABILITIES"
    "__NV_PRIME_RENDER_OFFLOAD"
    "__NV_PRIME_RENDER_OFFLOAD_PROVIDER"
    "__GLX_VENDOR_LIBRARY_NAME"
    "__VK_LAYER_NV_optimus"
    "VK_ICD_FILENAMES"
    "GNOME_KEYRING_CONTROL"
    "SSH_AUTH_SOCK"
    "GIO_LAUNCHED_DESKTOP_FILE"
    "GIO_LAUNCHED_DESKTOP_FILE_PID"
  ];

  chromeDevtoolsMcp = pkgs.writeShellApplication {
    name = "executor-chrome-devtools-mcp";
    runtimeInputs = [
      pkgs.nodejs
      pkgs.curl
      pkgs.coreutils
    ];
    text = ''
      cdp="http://127.0.0.1:${chromeCdpPort}/json/version"
      if [[ ! -f ${lib.escapeShellArg mcpJs} ]]; then
        echo "executor-chrome-devtools-mcp: missing ${mcpJs}" >&2
        echo "install with: npm --prefix ${dataDir}/mcp install chrome-devtools-mcp@1.8.0" >&2
        exit 1
      fi
      deadline=$((SECONDS + 20))
      while ! curl -fsS --max-time 1 "$cdp" >/dev/null; do
        if (( SECONDS >= deadline )); then
          echo "executor-chrome-devtools-mcp: Chromium CDP not ready at $cdp" >&2
          exit 1
        fi
        sleep 0.2
      done
      exec node ${lib.escapeShellArg mcpJs} \
        --browserUrl="http://127.0.0.1:${chromeCdpPort}" \
        --viewport=1280x720 \
        --no-usage-statistics \
        --no-performance-crux \
        --acceptInsecureCerts \
        "$@"
    '';
  };

  chromePre = pkgs.writeShellApplication {
    name = "executor-chrome-pre";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      mkdir -p ${lib.escapeShellArg chromeProfile}
      rm -f \
        ${lib.escapeShellArg chromeProfile}/SingletonLock \
        ${lib.escapeShellArg chromeProfile}/SingletonSocket \
        ${lib.escapeShellArg chromeProfile}/SingletonCookie
    '';
  };

  # Close oldest type=page targets when Chromium has more than 8 tabs.
  # MCP has close_page but Executor respawns stdio per call, so tabs accumulate.
  chromeGc = pkgs.writeShellApplication {
    name = "executor-chrome-gc";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      exec python3 - <<'PY'
      import json, os, sys, time, urllib.request

      KEEP = 8
      CDP = "http://127.0.0.1:${chromeCdpPort}"
      STATE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "executor-chrome-gc.json")

      def get(path):
          with urllib.request.urlopen(CDP + path, timeout=2) as response:
              return response.read()

      try:
          targets = json.loads(get("/json/list"))
      except Exception:
          sys.exit(0)

      pages = [t for t in targets if t.get("type") == "page" and "id" in t]
      now = time.time()
      try:
          with open(STATE) as handle:
              seen = json.load(handle)
      except Exception:
          seen = {}

      ids = {page["id"] for page in pages}
      seen = {key: value for key, value in seen.items() if key in ids}
      for page in pages:
          seen.setdefault(page["id"], now)

      if len(pages) > KEEP:
          ranked = sorted(pages, key=lambda page: (seen.get(page["id"], now), page["id"]))
          n_close = min(len(pages) - KEEP, len(pages) - 1)
          for page in ranked[:n_close]:
              try:
                  get("/json/close/" + page["id"])
                  seen.pop(page["id"], None)
                  print("closed", page["id"], page.get("url", ""), file=sys.stderr)
              except Exception as err:
                  print("close failed", page["id"], err, file=sys.stderr)

      with open(STATE, "w") as handle:
          json.dump(seen, handle)
      PY
    '';
  };

  daemonPre = pkgs.writeShellApplication {
    name = "executor-daemon-pre";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.sqlite
    ];
    text = ''
      mkdir -p ${lib.escapeShellArg dataDir}
      db=${lib.escapeShellArg "${dataDir}/data.db"}
      cmd=${lib.escapeShellArg mcpWrapperPath}
      if [[ ! -f "$db" ]]; then
        exit 0
      fi
      # Catalog "add" writes `npx @latest`. Pin back to the local wrapper.
      sqlite3 "$db" "UPDATE integration
        SET config = json_set(
              json_set(
                json_set(config, '$.transport', 'stdio'),
                '$.command', '$cmd'
              ),
              '$.args', json('[]')
            ),
            updated_at = strftime('%s','now')
        WHERE slug = 'chrome_devtools';"
    '';
  };
in
lib.mkIf cfg.executor.enable {
  home.packages = [
    executor
    chromeDevtoolsMcp
    chromeGc
  ];

  # Stable path so SQLite does not need a store-hash update on every rebuild.
  # force: the live wrapper was a regular file; HM must replace it with the store link.
  home.file.".executor/mcp/chrome-devtools-mcp" = {
    source = lib.getExe chromeDevtoolsMcp;
    force = true;
  };

  # Long-lived headless Chromium so chrome-devtools MCP can attach instead of
  # launching a new browser on every stdio spawn. Port 9223 avoids colliding
  # with the interactive `chrome-debug` helper on 9222.
  systemd.user.services.executor-chrome = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit = {
      Description = "Headless Chromium for Executor chrome-devtools MCP";
      After = [ "default.target" ];
      StartLimitIntervalSec = 60;
      StartLimitBurst = 5;
    };
    Service = {
      Type = "simple";
      ExecStartPre = lib.getExe chromePre;
      ExecStart = lib.concatStringsSep " " [
        (lib.getExe pkgs.chromium)
        "--headless=new"
        "--no-sandbox"
        "--remote-debugging-address=127.0.0.1"
        "--remote-debugging-port=${chromeCdpPort}"
        "--remote-allow-origins=*"
        "--user-data-dir=${chromeProfile}"
        "--crash-dumps-dir=${chromeProfile}/crashes"
        "--disk-cache-dir=${chromeProfile}/cache"
        "--no-first-run"
        "--no-default-browser-check"
        "--noerrdialogs"
        "--disable-gpu"
        "--disable-gpu-compositing"
        "--ozone-platform=headless"
        "--ozone-override-screen-size=1280,720"
        "--use-angle=swiftshader-webgl"
        "--enable-unsafe-swiftshader"
        "--disable-dev-shm-usage"
        "--disable-background-networking"
        "--disable-sync"
        "--disable-extensions"
        "--disable-default-apps"
        "--disable-component-update"
        "--disable-breakpad"
        "--disable-crash-reporter"
        "--disable-hang-monitor"
        "--disable-ipc-flooding-protection"
        "--disable-client-side-phishing-detection"
        "--disable-domain-reliability"
        "--disable-backgrounding-occluded-windows"
        "--disable-renderer-backgrounding"
        "--disable-background-timer-throttling"
        "--disable-notifications"
        "--disable-speech-api"
        "--disable-site-isolation-trials"
        "--renderer-process-limit=4"
        "--mute-audio"
        "--hide-scrollbars"
        "--metrics-recording-only"
        "--password-store=basic"
        "--log-level=3"
        "--disable-features=Translate,MediaRouter,OptimizationHints,PaintHolding,InterestFeedContentSuggestions,AudioServiceOutOfProcess,CalculateNativeWinOcclusion,PushMessaging"
      ];
      # Session bus makes every navigation wait on a D-Bus call until Puppeteer's
      # 10s load timeout. Dummy address fails immediately (same as executor).
      Environment = [ "DBUS_SESSION_BUS_ADDRESS=unix:path=%t/executor-no-bus" ];
      UnsetEnvironment = graphicalUnset;
      Restart = "always";
      RestartSec = "2s";
      MemoryMax = "2G";
      TasksMax = "256";
      TimeoutStopSec = "10s";
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.executor-chrome-gc = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit = {
      Description = "Garbage-collect extra Executor Chromium tabs";
      After = [ "executor-chrome.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe chromeGc;
    };
  };

  systemd.user.timers.executor-chrome-gc = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit = {
      Description = "Garbage-collect extra Executor Chromium tabs";
      After = [ "executor-chrome.service" ];
    };
    Timer = {
      OnBootSec = "2m";
      OnUnitActiveSec = "5m";
      AccuracySec = "30s";
      Persistent = false;
      Unit = "executor-chrome-gc.service";
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # Own the supervised daemon in Home Manager instead of `executor install`,
  # which would write ~/.config/systemd/user/sh.executor.daemon.service
  # outside the store. The unit name matches upstream so `executor service status`
  # still sees a registered service.
  systemd.user.services."sh.executor.daemon" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit = {
      Description = "Executor supervised daemon";
      After = [
        "default.target"
        "executor-chrome.service"
      ]
      ++ lib.optionals serveCfg.enable [ "tailscaled.service" ];
      Wants = [ "executor-chrome.service" ] ++ lib.optionals serveCfg.enable [ "tailscaled.service" ];
    };
    Service = {
      Type = "simple";
      ExecStart =
        "${executor}/bin/executor daemon run --foreground --port ${port} --hostname 127.0.0.1"
        + lib.optionalString (extraArgs != [ ]) (" " + lib.concatStringsSep " " extraArgs);
      Restart = "on-failure";
      RestartSec = "5s";
      # The bun binary ignores SIGTERM until the HTTP server is up.
      TimeoutStopSec = "10s";
      KillMode = "mixed";
      KillSignal = "SIGTERM";
      SendSIGKILL = "yes";
      WorkingDirectory = dataDir;
      ExecStartPre = lib.getExe daemonPre;
      Environment = [
        "EXECUTOR_SUPERVISED=1"
        "EXECUTOR_DATA_DIR=${dataDir}"
        # Scope defaults to cwd; pin it so boot does not walk $HOME.
        "EXECUTOR_SCOPE_DIR=${dataDir}"
        "EXECUTOR_SERVICE_VERSION=${executor.version}"
        "EXECUTOR_DISABLE_ANALYTICS=1"
        "DO_NOT_TRACK=1"
        # User systemd has a short PATH and no node. stdio MCP (`npx …`) needs
        # nodejs; chrome-devtools-mcp launches Chromium, not Google Chrome.
        "PATH=${
          lib.makeBinPath [
            pkgs.nodejs
            pkgs.coreutils
            pkgs.chromium
            chromeDevtoolsMcp
          ]
        }:${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
        "CHROME_PATH=${lib.getExe pkgs.chromium}"
        # keyring.node talks to org.freedesktop.secrets over the session bus and
        # waits forever for an unlock prompt. Point dbus at a missing socket so
        # it fails immediately; file-secrets is the durable store.
        "DBUS_SESSION_BUS_ADDRESS=unix:path=%t/executor-no-bus"
      ];
      UnsetEnvironment = graphicalUnset;
    }
    // lib.optionalAttrs serveCfg.enable {
      # `-` so a missing tailscale session does not take the daemon down.
      # Additive: does not reset the rest of this node's serve config.
      ExecStartPost = "-${pkgs.tailscale}/bin/tailscale serve --bg --yes --https=${httpsPort} http://127.0.0.1:${port}";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
