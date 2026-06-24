{ pkgs, ... }:
{
  imports = [
    ../../modules/home
  ];

  home.packages = with pkgs; [
    kicad

    jetbrains-toolbox
    jetbrains.idea
  ];

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    exec = [ "pkill swaybg; swaybg --image ${./wallpaper.jpg}" ];

    monitor = [
      # "DP-3, 5120x1440@240, auto, 1, cm, wide, vrr, 0, bitdepth, 10"
    ];

    env = [
      "ELECTRON_OZONE_PLATFORM_HINT,auto"
    ];
  };

  home.stateVersion = "26.05";
}
