{
  imports = [ ../../modules/home ];

  xdg.configFile."emacs/init.el".source = ./init.el;
  programs.emacs.enable = true;

  services.wallpaper = {
    enable = true;
    path = ./wallpaper.heic;
  };

  home.stateVersion = "23.11";
}
