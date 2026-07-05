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

  # Host-specific Hyprland facts, loaded by the shared config.lua via `require("host")`.
  # ThinkPad X1 Carbon Gen 13 (laptop): let Hyprland auto-configure the internal
  # eDP panel and any docked/external outputs.
  xdg.configFile."hypr/host.lua".text = ''
    hl.monitor({
      output = "",
      mode = "preferred",
      position = "auto",
      scale = "auto",
    })

    hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

    -- No wallpaper set for this host yet. To add one, drop hosts/carbon/wallpaper.jpg
    -- and uncomment (host.lua is generated from home.nix, so edit it there):
    -- hl.on("hyprland.start", function()
    --   hl.exec_cmd("pkill swaybg; swaybg --image <wallpaper>")
    -- end)
  '';

  home.stateVersion = "26.05";
}
