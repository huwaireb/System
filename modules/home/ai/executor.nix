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
    else
      "https://${hostName}.${serveCfg.domain}:${httpsPort}";
  extraArgs = lib.optionals (serveCfg.enable && tailnetOrigin != null) [
    "--allowed-host"
    tailnetOrigin
  ];
in
lib.mkIf cfg.executor.enable {
  home.packages = [ executor ];

  # Own the supervised daemon in Home Manager instead of `executor install`,
  # which would write ~/.config/systemd/user/sh.executor.daemon.service
  # outside the store. The unit name matches upstream so `executor service status`
  # still sees a registered service.
  systemd.user.services."sh.executor.daemon" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit = {
      Description = "Executor supervised daemon";
      After = [ "default.target" ] ++ lib.optionals serveCfg.enable [ "tailscaled.service" ];
      Wants = lib.optionals serveCfg.enable [ "tailscaled.service" ];
    };
    Service = {
      Type = "simple";
      ExecStart =
        "${executor}/bin/executor daemon run --foreground --port ${port} --hostname 127.0.0.1"
        + lib.optionalString (extraArgs != [ ]) (" " + lib.concatStringsSep " " extraArgs);
      Restart = "on-failure";
      RestartSec = "5s";
      WorkingDirectory = config.home.homeDirectory;
      Environment = [
        "EXECUTOR_SUPERVISED=1"
        "EXECUTOR_DATA_DIR=${config.home.homeDirectory}/.executor"
        "EXECUTOR_SERVICE_VERSION=${executor.version}"
        "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
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
