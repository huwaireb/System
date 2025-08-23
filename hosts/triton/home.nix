{
  imports = [
    ../../modules/home
    ../../modules/home/hyprland.nix
  ];

  xdg.configFile."emacs/init.el".source = ./init.el;

  programs.emacs.enable = true;

  home.stateVersion = "25.05";
}
