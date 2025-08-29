{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/nixos/wayland
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

  programs.steam.enable = true;

  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  system.stateVersion = "25.05";
}
