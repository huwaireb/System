{ lib, pkgs, config, ... }:
lib.mkIf config.ai.agents.enable {
  home.packages = with pkgs; [
    pi-coding-agent # `pi`
    claude-code     # `claude`
  ];
}
