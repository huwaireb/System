{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) optionals;
in
{
  imports = [
    ./term.nix
    ../system.nix
  ];

  home.packages =
    with pkgs;
    [
      iosevka
      nerd-fonts.iosevka
    ]
    ++ optionals config.isDarwin [
      stats
      raycast
      alt-tab-macos
    ];

  fonts.fontconfig.enable = true;
  programs.home-manager.enable = true;

  home.stateVersion = "23.11";
}
