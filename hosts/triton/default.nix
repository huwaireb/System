{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "triton";

  nixpkgs.hostPlatform = "x86_64-linux";
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

  system.stateVersion = "25.05";
}
