{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "triton";

  home-manager.users.rmu = import ./home.nix;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.rmu = {
    isNormalUser = true;
    initialPassword = "makebarty";
    extraGroups = [ "wheel" ];
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.openssh.enable = true;
  services.xserver.enable = true;

  programs.xwayland.enable = true;
  xdg.portal = {
    enable = true;
    config.common.default = "*";

    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
    ];

    configPackages = [
      pkgs.hyprland
    ];
  };

  system.stateVersion = "25.05";
}
