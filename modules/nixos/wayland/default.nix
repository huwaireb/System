{ pkgs, ... }:
{
  imports = [
    ./dunst.nix
    ./hyprland
  ];

  environment.systemPackages = with pkgs; [
    grim
    slurp
    swappy
    swaybg
    wl-clipboard
    wtype
    hyprpicker
    playerctl
    xdg-utils
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
