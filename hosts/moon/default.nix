lib:
lib.darwinSystem' {
  imports = [
    ../../modules/home.nix
    ../../modules/darwin/brew.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "rmu";
  networking.computerName = "moon";

  home-manager.users.rmu.imports = [
    ../../modules/home
    ../../modules/home/zed.nix
  ];

  system.stateVersion = 5;
}
