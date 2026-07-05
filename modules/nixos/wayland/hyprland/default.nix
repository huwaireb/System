{
  pkgs,
  config,
  ...
}:
{
  imports = [ ../fuzzel.nix ];

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.hyprland.enableGnomeKeyring = true;

  programs.hyprland.enable = true;

  xdg.portal = {
    enable = true;
    config.common.default = "*";

    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
    ];

    configPackages = [
      pkgs.hyprland
    ];
  };

  home-manager.sharedModules = [
    (
      { config, pkgs, ... }:
      {
        wayland.windowManager.hyprland.enable = false;

        xdg.configFile."hypr/hyprland.lua".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/modules/nixos/wayland/hyprland/config.lua";

        home.file.".local/share/hypr/stubs".source = "${pkgs.hyprland}/share/hypr/stubs";
      }
    )
  ];
}
