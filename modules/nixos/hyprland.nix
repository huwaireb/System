{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) flatten;
in
{
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.hyprland.enableGnomeKeyring = true;

  environmentPackages = with pkgs; [
    grim
    slurp
    swappy
    swaybg
    wl-clipboard
    wtype
    xdg-utils
    kdePackages.xwaylandvideobridge
  ];

  programs.xwayland.enable = true;
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
    {
      wayland.windowManager.hyprland = {
        systemd.enable = true;
        systemd.enableXdgAutostart = true;

        settings = {
          bind = flatten [
            "SUPER      , RETURN, exec, ghostty --gtk-single-instance=true"
          ];

          misc = {
            animate_manual_resizes = true;

            disable_hyprland_logo = true;
            disable_splash_rendering = true;

            key_press_enables_dpms = true;
            mouse_move_enables_dpms = true;
          };
        };
      };
    }
  ];
}
