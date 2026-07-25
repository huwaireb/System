{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf config.ai.agents.enable {
  home.packages = with pkgs; [
    codex
    codex-acp
    claude-code
    claude-code-acp
    pi-coding-agent # `pi`
  ];
}
