{
  imports = [
    ../../modules/home
    ../../modules/home/services/wallpaper
  ];

  xdg.configFile."emacs/init.el".source = ./init.el;

  programs.emacs.enable = false;
  programs.zed-editor.enable = true;

  services.wallpaper = {
    enable = true;
    path = ./wallpaper.heic;
  };

  programs.lan-mouse.enable = true;

  home.stateVersion = "23.11";
}
