{
  imports = [
    ../../modules/home
  ];

  xdg.configFile."emacs/init.el".source = ./init.el;
  programs.emacs.enable = false;

  wayland.windowManager.hyprland.settings.monitor = [
    "DP-2, 3440x1440@175, auto, 1, cm, hdr, vrr, 1, bitdepth, 10"
  ];

  home.stateVersion = "25.05";
}
