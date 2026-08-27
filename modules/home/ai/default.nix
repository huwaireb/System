{ lib, config, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    mkDefault
    types
    ;
  cfg = config.ai;
in
{
  imports = [
    ./agents.nix
    ./executor.nix
    ./herdr.nix
    ./moshi.nix
    ./pi.nix
  ];

  options.ai = {
    enable = mkEnableOption "AI coding tooling (agents + pi config + herdr)";

    configRoot = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Projects/github.huwaireb/System/modules/home/ai/config";
      description = "Absolute path to the vendored AI config in the repo working tree (symlink target root).";
    };

    agents.enable = mkEnableOption "AI agent CLIs";
    pi.enable = mkEnableOption "pi config symlinks (~/.pi, ~/.agents) + extension npm install";
    herdr.enable = mkEnableOption "herdr agent multiplexer + config";
    moshi.enable = mkEnableOption "moshi-hook session-pairing daemon (systemd user service)";
    executor.enable = mkEnableOption "executor CLI + local daemon (systemd user service)";
    executor.port = mkOption {
      type = types.port;
      default = 4788;
      description = "Loopback port for the local Executor daemon.";
    };
    executor.tailscaleServe = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Expose the daemon on the tailnet with `tailscale serve` (HTTPS, tailnet
          only). Does not enable Funnel. The daemon stays bound to 127.0.0.1.
        '';
      };
      httpsPort = mkOption {
        type = types.port;
        default = 443;
        description = ''
          HTTPS port on the MagicDNS name. 443 is https://triton.tail43612.ts.net
          (no port in the URL). Other values become https://host:port.
        '';
      };
      domain = mkOption {
        type = types.str;
        default = "tail43612.ts.net";
        description = "MagicDNS tailnet suffix used for CORS --allowed-host.";
      };
    };
  };

  # Convenience: `ai.enable = true` turns on the common set (hosts can still override).
  config = mkIf cfg.enable {
    ai.agents.enable = mkDefault true;
    ai.pi.enable = mkDefault true;
    ai.herdr.enable = mkDefault true;
  };
}
