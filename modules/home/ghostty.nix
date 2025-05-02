{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.ghostty = {
    enable = true;

    # Don't actually install Ghostty if we are on Darwin.
    # Unavailable because Ghostty uses Xcode and Swift is behind a major release in nixpkgs.
    package = lib.mkIf config.isDarwin (pkgs.writeScriptBin "not-ghostty" "");

    # Bat syntax points to emptyDirectory.
    installBatSyntax = !config.isDarwin;

    settings = {
      font-family = "Iosevka";
      font-size = 24;

      theme = "GruvboxDark";

      background-opacity = 0.8;
      background-blur-radius = 80;

      window-padding-x = 15;
      window-padding-y = 15;
      window-padding-color = "extend-always";

      macos-non-native-fullscreen = "visible-menu";
      macos-option-as-alt = "left";

      mouse-hide-while-typing = true;

      macos-titlebar-style = "tabs";

      window-colorspace = "display-p3";

      keybind = [ "global:grave_accent=toggle_quick_terminal" ];
    };
  };
}
