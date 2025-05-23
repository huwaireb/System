{
  imports = [ ../../modules/home ];

  xdg.configFile."emacs/init.el".source = ./init.el;
  programs.emacs.enable = true;

  services.wallpaper = {
    enable = true;
    path = ./wallpaper.jpg;
  };

  home.stateVersion = "23.11";
}
