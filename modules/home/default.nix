{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  imports = [
    ./term.nix
    ../system.nix
  ];

  home.stateVersion = "23.11";

  home.packages = [
    pkgs.iosevka
    pkgs.nerd-fonts.iosevka
    (mkIf config.isDarwin pkgs.alt-tab-macos)
  ];

  fonts.fontconfig.enable = true;
  programs.home-manager.enable = true;
}
