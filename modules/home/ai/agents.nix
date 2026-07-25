{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  localPackages = self.packages.${pkgs.stdenv.hostPlatform.system};
in
lib.mkIf config.ai.agents.enable {
  home.packages = [
    localPackages.codex
    localPackages.codex-acp
    localPackages.claude-code
    localPackages.claude-code-acp
    pkgs.pi-coding-agent # `pi`
  ];
}
