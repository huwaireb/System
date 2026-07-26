{ pkgs, ... }:
{
  imports = [
    ../../modules/home
    ../../modules/home/services/wallpaper
  ];

  xdg.configFile."emacs/init.el".source = ./init.el;

  programs.emacs.enable = false;
  programs.zed-editor.enable = true;

  ai.agents.enable = true;
  ai.herdr.enable = true;

  services.wallpaper = {
    enable = true;
    path = ./wallpaper.heic;
  };

  home.packages = [
    pkgs.moonlight-qt
    pkgs.jetbrains-toolbox
  ];

  home.stateVersion = "23.11";
}
