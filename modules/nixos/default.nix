{ pkgs, ... }:
{
  imports = [
    ./gtk.nix
    ./kernel.nix
    ./oom.nix
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
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    settings = {
      # Collect garbage during builds once free space drops below 100 GiB,
      # until 300 GiB are free.
      min-free = 100 * 1024 * 1024 * 1024;
      max-free = 300 * 1024 * 1024 * 1024;

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
