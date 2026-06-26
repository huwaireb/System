{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/nixos/wayland
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.enableIPv6 = false;
  networking.hostName = "carbon";

  networking.networkmanager.enable = true;

  home-manager.users.rmu = import ./home.nix;
  users.users.rmu = {
    isNormalUser = true;
    initialPassword = "makebarty";
    extraGroups = [
      "wheel"
      "kvm"
      "libvirtd"
      "networkmanager"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBMRKAc1asly75a8w7LNkOBFYdskjWOgLAJ09lc7W7tVZbvsNOcDh+3FB8MG+Zkl6jrYbQ541SsfOiRZ6FCUIV2MAAAALaWRAYmxpbmsuc2g= user@ipad"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFM0CwQ/afmHExkS2LtUEuJ1q/Uz9PKBbo1fVd2wiEI1 pub@rmu.ae"
    ];
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.openssh.enable = true;
  programs.mosh.enable = true;
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  virtualisation.libvirtd.enable = true;
  environment.systemPackages = with pkgs; [
    tailscale
    virt-manager
    qemu
  ];

  networking.firewall.enable = true;

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  programs.nix-ld.enable = true;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
