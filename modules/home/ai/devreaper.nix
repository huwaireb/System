{ pkgs, lib, config, ... }:
let
  cfg = config.ai;
  devreaper = pkgs.writers.writePython3Bin "devreaper" {
    flakeIgnore = [ "E501" "W503" ];
  } (builtins.readFile ./devreaper.py);
in
lib.mkIf (cfg.devreaper.enable && pkgs.stdenv.hostPlatform.isLinux) {
  home.packages = [ devreaper ];

  # Agents start vite / process-compose / postgres and walk away; each idle
  # vite alone holds 3-4 GiB. See devreaper.py for the idleness heuristic.
  systemd.user.services.devreaper = {
    Unit.Description = "Reap idle agent-started dev servers";
    Service = {
      Type = "oneshot";
      ExecStart = "${devreaper}/bin/devreaper";
      Environment = [
        "DEVREAPER_IDLE_MIN=${toString cfg.devreaper.idleMinutes}"
        "DEVREAPER_ORPHAN_MIN=15"
      ];
    };
  };

  systemd.user.timers.devreaper = {
    Unit.Description = "Reap idle agent-started dev servers";
    Timer = {
      OnBootSec = "5min";
      OnUnitActiveSec = "5min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
