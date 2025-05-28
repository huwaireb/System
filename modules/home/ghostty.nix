{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (pkgs) stdenv writeScriptBin;

  is-desktop = config.type == "desktop";
  is-darwin = stdenv.hostPlatform.isDarwin;
in
{
  programs.ghostty = {
    enable = is-desktop;

    # Don't actually install Ghostty if we are on Darwin.
    # Unavailable because Ghostty uses Xcode and Swift is behind a major release in nixpkgs.
    package = lib.mkIf is-darwin (writeScriptBin "not-ghostty" "");

    # Bat syntax points to emptyDirectory.
    installBatSyntax = !is-darwin;

    settings = {
      font-family = "Iosevka Nerd Font";
      font-size = 24;

      theme = "tokyonight";

      background-opacity = 0.8;
      background-blur-radius = 80;

      window-padding-x = 15;
      window-padding-y = 15;
      window-padding-color = "extend-always";

      window-save-state = "always";

      macos-non-native-fullscreen = "visible-menu";
      macos-option-as-alt = "left";
      macos-titlebar-style = "tabs";

      mouse-hide-while-typing = true;

      window-colorspace = "display-p3";

      keybind = [ "global:f3=toggle_quick_terminal" ];
    };
  };
}
