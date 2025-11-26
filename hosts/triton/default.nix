{ pkgs, config, ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/nixos/wayland
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.enableIPv6 = false;
  networking.hostName = "triton";

  home-manager.users.rmu = import ./home.nix;
  users.users.rmu = {
    isNormalUser = true;
    initialPassword = "makebarty";
    extraGroups = [
      "wheel"
      "kvm"
      "libvirtd"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBMRKAc1asly75a8w7LNkOBFYdskjWOgLAJ09lc7W7tVZbvsNOcDh+3FB8MG+Zkl6jrYbQ541SsfOiRZ6FCUIV2MAAAALaWRAYmxpbmsuc2g= user@ipad"
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

  programs.steam.enable = true;

  virtualisation.libvirtd.enable = true;
  environment.systemPackages = with pkgs; [
    tailscale
    virt-manager
    qemu
    claude-code
    nodejs
  ];

  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true;
    openFirewall = true;
    settings.origin_web_ui_allowed = "wan";
  };

  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      22
      80
      443
      631
      11434
    ];

    allowedUDPPorts = [
      631
      config.services.tailscale.port
      5353
      11434
    ];
  };

  system.stateVersion = "25.05";
}
