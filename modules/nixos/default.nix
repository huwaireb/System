{ pkgs, ... }:
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
    package = pkgs.nixVersions.latest;

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
      ];

      trusted-users = [
        "@wheel"
        "@admin"
      ];
    };
  };
}
