{
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./term.nix ];

  home.stateVersion = "23.11";

  home.packages =
    with pkgs;
    [
      iosevka
      nerd-fonts.iosevka
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.alt-tab-macos ];

  fonts.fontconfig.enable = true;
  programs.home-manager.enable = true;
}
