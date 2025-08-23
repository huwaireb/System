{
  imports = [
    ./home.nix
    ./hardware.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  home-manager.users.rmu = import ./home.nix;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.rmu = {
    isNormalUser = true;
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
  };

  system.stateVersion = "25.05";
}
