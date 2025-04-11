{ pkgs, ... }:
{
  gtk = {
    enable = true;
    theme = {
      name = "GruvboxDark";
      package = pkgs.gruvbox-gtk-theme;
    };
  };
}
