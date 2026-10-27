{
  self,
  pkgs,
  config,
  options,
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

  # BFQ instead of kyber on NVMe: kyber ignores cgroup io weights, so the
  # t3code.service IOWeight=1000 did nothing and on-disk test Postgres
  # writeback starved the t3 server's SQLite fsyncs (multi-second stalls,
  # client reconnect loops).
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="bfq"
  '';

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
    # t3code.service (from `t3 service install`) runs in the user manager;
    # keep it up without a login session.
    linger = true;
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
    ];

    allowedUDPPorts = [
      631
      config.services.tailscale.port
      5353
      51820
    ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  programs.nix-ld.enable = true;
  # T3 Code's preview browser is a downloaded Chrome build; nix-ld must supply
  # its shared libraries. Assigning the list replaces the module default, so
  # extend that default rather than dropping zlib/openssl/curl/etc.
  programs.nix-ld.libraries =
    options.programs.nix-ld.libraries.default
    ++ (with pkgs; [
      glib
      nspr
      nss
      at-spi2-core # atk, atk-bridge, atspi
      dbus
      expat
      libgbm
      libxkbcommon
      systemd
      alsa-lib
      libx11
      libxcb
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      # Not in T3's first error but loaded right after by headless Chrome.
      pango
      cairo
      cups
      libdrm
    ]);

  security.pki.caCertificateBlacklist = [
    # CVE-2026-111943
    "Comodo AAA Services root"
    # https://hg-edge.mozilla.org/projects/nss/rev/26d38a0c3fb81e7fb2acedbaf4c42dd21dce0517
    "emSign ECC Root CA - G3"
    # https://hg-edge.mozilla.org/projects/nss/rev/8159223c48ceeb1273a1915bca95a517294ab0e0
    "emSign Root CA - C1"
    "emSign ECC Root CA - C3"
  ];

  system.stateVersion = "25.05";
}
