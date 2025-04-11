{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  nix = {
    enable = true;
    package = pkgs.nixVersions.latest;

    registry = {
      nixpkgs.to = lib.mkForce {
        type = "path";
        path = inputs.nixpkgs;
      };
    };

    settings = {
      keep-outputs = true;
      keep-derivations = true;
      experimental-features = "nix-command flakes pipe-operators fetch-closure";

      extra-platforms = lib.optionals (pkgs.stdenv.isDarwin) [
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      trusted-users = [
        "root"
        "@wheel"
      ];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
