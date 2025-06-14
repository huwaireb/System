{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../system.nix

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
    ./services/wallpaper
  ];

  home.packages = lib.mkIf (config.type == "desktop") (
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

  fonts.fontconfig.enable = true;
  programs.home-manager.enable = true;
}
