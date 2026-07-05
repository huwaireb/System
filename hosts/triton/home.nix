{ pkgs, ... }:
{
  imports = [
    ../../modules/home
  ];

  home.packages = with pkgs; [
    kicad

    jetbrains-toolbox
    jetbrains.idea
  ];

  xdg.configFile."emacs/init.el".source = ./init.el;
  programs.emacs.enable = false;

  # Host-specific Hyprland facts, loaded by the shared config.lua via `require("host")`.
  xdg.configFile."hypr/host.lua".text = ''
    hl.monitor({
      output = "DP-3",
      mode = "5120x1440@240",
      position = "auto",
      scale = 1,
      cm = "wide",
      vrr = 0,
      bitdepth = 10,
    })

    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
    hl.env("NVD_BACKEND", "direct")

    hl.on("hyprland.start", function()
      hl.exec_cmd("pkill swaybg; swaybg --image ${./wallpaper.jpg}")
    end)
  '';

  home.stateVersion = "25.05";
}
