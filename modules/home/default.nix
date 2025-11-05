{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  is-desktop = config.type == "desktop";
in
{
  imports = [
    ../system.nix

    ./helix.nix
    ./emacs.nix
    ./gpg.nix
    ./ssh.nix
    ./terminal.nix
    ./shell.nix
    ./version-control.nix

    # Desktop
    ./zed.nix
    ./ghostty.nix
    ./browser.nix

    inputs.lan-mouse.homeManagerModules.default
  ];

  home.packages = lib.mkIf is-desktop (
    with pkgs;
    [
      iosevka
      nerd-fonts.iosevka
    ]
    ++ lib.optionals stdenv.isDarwin [
      stats
      alt-tab-macos
    ]
  );

  fonts.fontconfig.enable = is-desktop;
  programs.home-manager.enable = true;
}
