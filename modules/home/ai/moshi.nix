{ self, pkgs, lib, config, ... }:
let
  cfg = config.ai;
  moshi-hook = self.packages.${pkgs.stdenv.hostPlatform.system}.moshi-hook;
in
lib.mkIf cfg.moshi.enable {
  home.packages = [ moshi-hook ];

  systemd.user.services.moshi-hook = {
    Unit = {
      Description = "moshi-hook local hook daemon (socket + Moshi bridge)";
      After = [ "network-online.target" ];
    };
    Service = {
      ExecStart = "${moshi-hook}/bin/moshi-hook serve";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
