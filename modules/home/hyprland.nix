{ config, pkgs, ... }:
let
  inherit (lib) flatten;
  inherit (pkgs) stdenv lib;

  is-desktop = config.type == "desktop";
  is-linux = stdenv.hostPlatform.isLinux;
in
{
  home.packages = with pkgs; [
    grim
    slurp
    swappy
    swaybg
    wl-clipboard
    wtype
    xdg-utils
    xwaylandvideobridge
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

  wayland.windowManager.hyprland = {
    enable = is-desktop && is-linux;
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
