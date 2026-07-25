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
  };

  # Convenience: `ai.enable = true` turns on the common set (hosts can still override).
  config = mkIf cfg.enable {
    ai.agents.enable = mkDefault true;
    ai.pi.enable = mkDefault true;
    ai.herdr.enable = mkDefault true;
  };
}
