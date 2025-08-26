{ pkgs, ... }:
{
  imports = [
    ./dunst.nix
    ./hyprland.nix
  ];

  environment.systemPackages = with pkgs; [
    grim
    slurp
    swappy
    swaybg
    wl-clipboard
    wtype
    xdg-utils
    kdePackages.xwaylandvideobridge
  ];

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = false;
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd hyprland";
      user = "greeter";
    };
  };

  programs.xwayland.enable = true;
}
