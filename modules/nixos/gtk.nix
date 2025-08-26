{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  is-desktop = config.type == "desktop";
in
mkIf is-desktop {
  environment.systemPackages = [ pkgs.dconf ];
  home-manager.sharedModules = [
    {
      gtk = {
        enable = true;
        theme = {
          name = "Tokyonight-Dark";
          package = pkgs.tokyonight-gtk-theme.override {
            tweakVariants = [ "macos" ];
          };
        };

        font = {
          name = "Iosevka Nerd Font";
          size = 16;
        };
      };

      home.pointerCursor = {
        gtk.enable = is-desktop;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 16;
      };
    }
  ];
}
