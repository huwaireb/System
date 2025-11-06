{ pkgs, ... }:
{
  imports = [
    ../../modules/home
  ];

  home.packages = with pkgs; [
    jetbrains.gateway
    jetbrains.idea-ultimate
    kicad
  ];

  xdg.configFile."emacs/init.el".source = ./init.el;
  programs.emacs.enable = false;

  programs.zed-editor.enable = true;

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    exec = [ "pkill swaybg; swaybg --image ${./wallpaper.jpg}" ];

    monitor = [
      "DP-3, 5120x1440@240, auto, 1, cm, wide, vrr, 0, bitdepth, 10"
    ];

    env = [
      "LIBVA_DRIVER_NAME,nvidia"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      "ELECTRON_OZONE_PLATFORM_HINT,auto"
      "NVD_BACKEND,direct"
    ];
  };

  programs.lan-mouse.enable = true;

  home.stateVersion = "25.05";
}
