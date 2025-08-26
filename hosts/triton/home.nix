{ pkgs, ... }:
{
  imports = [
    ../../modules/home
  ];

  home.packages = with pkgs; [
    jetbrains.gateway
    jetbrains.idea-ultimate
  ];

  xdg.configFile."emacs/init.el".source = ./init.el;
  programs.emacs.enable = false;

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-2, 3440x1440@175, auto, 1, cm, hdr, vrr, 1, bitdepth, 10"
    ];

    env = [
      "LIBVA_DRIVER_NAME,nvidia"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      "ELECTRON_OZONE_PLATFORM_HINT,auto"
      "NVD_BACKEND,direct"
    ];
  };

  home.stateVersion = "25.05";
}
