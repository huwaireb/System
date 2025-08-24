{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/nixos/wayland.nix
    ../../modules/nixos/hyprland.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "triton";

  home-manager.users.rmu = import ./home.nix;
  users.users.rmu = {
    isNormalUser = true;
    initialPassword = "makebarty";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
