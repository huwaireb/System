{ pkgs, ... }:
{
  imports = [ ./term.nix ];

  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    iosevka
    nerd-fonts.iosevka
  ];

  fonts.fontconfig.enable = true;
  programs.home-manager.enable = true;
}
