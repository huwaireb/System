{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    xclip
  ];
  services.swww.enable = true;
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      theme = "GruvboxDark";
      font-family = "Iosevka";
      font-size = 24;

      window-padding-x = 15;
      window-padding-y = 15;
      window-padding-color = "extend-always";

      mouse-hide-while-typing = true;

      gtk-single-instance = true;

      window-theme = "dark";
      window-decoration = false;
    };
  };
}
