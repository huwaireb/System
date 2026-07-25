{
  self,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./buzz.nix
    ../../modules/nixos/wayland
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.enableIPv6 = false;
  networking.hostName = "triton";
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.10.10.7/24" ];
    listenPort = 51820;
    privateKeyFile = "/var/secrets/wg0";

    peers = [
      {
        publicKey = "4hXlp6yqQNbmnb/ROQko5lGG6zUS9qpRio3l1tCO5yQ=";
        allowedIPs = [
          "10.10.10.0/24"
          "10.10.10.3/32"
        ];
        endpoint = "vpn.trio.ae:51820";
        persistentKeepalive = 25;
      }
    ];
  };

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

  programs.steam.enable = true;

  virtualisation.libvirtd.enable = true;
  environment.systemPackages = with pkgs; [
    tailscale
    virt-manager
    qemu
    chromium
    self.packages.${pkgs.stdenv.hostPlatform.system}.moshi-hook
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
      51820
    ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  programs.nix-ld.enable = true;

  system.stateVersion = "25.05";
}
