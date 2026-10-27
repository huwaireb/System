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

  # v2's default data dir; pin it here so the service owns the path explicitly
  # and future channel moves (beta -> stable) can't silently relocate the DB.
  dataDir = "${config.home.homeDirectory}/.executor/v2/cli";
in
lib.mkIf cfg.executor.enable {
  home.packages = [ executor ];

  # Own the supervised daemon in Home Manager instead of `executor install`,
  # which would write ~/.config/systemd/user/sh.executor.daemon.service
  # outside the store. The unit name matches upstream so `executor service
  # status` still sees a registered service.
  systemd.user.services."sh.executor.daemon" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit = {
      Description = "Executor supervised daemon";
      After = [ "default.target" ] ++ lib.optionals serveCfg.enable [ "tailscaled.service" ];
      Wants = lib.optionals serveCfg.enable [ "tailscaled.service" ];
    };
    Service = {
      Type = "simple";
      # v2's headless start (no browser); MCP is served over HTTP at /mcp.
      ExecStart = "${executor}/bin/executor serve";
      Restart = "on-failure";
      RestartSec = "5s";
      TimeoutStopSec = "15s";
      Environment = [
        "EXECUTOR_PORT=${port}"
        "EXECUTOR_DATA_DIR=${dataDir}"
        # A systemd user session has no interactive Secret Service to unlock;
        # keep the API/encryption keys in keys.json instead of hanging on a
        # keyring prompt (mirrors v1's file-secrets choice).
        "EXECUTOR_KEY_STORAGE=file"
        "EXECUTOR_DISABLE_ANALYTICS=1"
        "DO_NOT_TRACK=1"
        # Nix owns updates; skip npm's daily self-update check.
        "EXECUTOR_NO_UPDATE_CHECK=1"
      ]
      ++ lib.optionals (serveCfg.enable && tailnetOrigin != null) [
        # Generated browser/connection links use the tailnet HTTPS origin
        # instead of http://127.0.0.1:${port} (v1's `--allowed-host`).
        "EXECUTOR_BROWSER_ORIGIN=${tailnetOrigin}"
      ];
    }
    // lib.optionalAttrs serveCfg.enable {
      # `-` so a missing tailscale session does not take the daemon down.
      # Additive: does not reset the rest of this node's serve config.
      ExecStartPost = "-${pkgs.tailscale}/bin/tailscale serve --bg --yes --https=${httpsPort} http://127.0.0.1:${port}";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
