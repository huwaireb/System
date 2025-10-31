{ inputs, pkgs, ... }:
{
  imports = [
    ./gtk.nix
    ./kernel.nix
  ];

  boot.tmp.cleanOnBoot = true;

  security.sudo.enable = true;
  security.sudo.extraConfig = ''
    Defaults lecture = never
    Defaults pwfeedback
  '';

  nix = {
    enable = true;
    package = inputs.nix.packages.${pkgs.system}.default;

    channel.enable = false;
    optimise.automatic = true;

    settings = {
      keep-outputs = true;
      keep-derivations = true;

      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      trusted-users = [
        "@wheel"
        "@admin"
      ];
    };
  };
}
