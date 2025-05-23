{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (pkgs) stdenv;
in
{
  imports = [ ./system.nix ];

  time.timeZone = lib.mkDefault "Asia/Dubai";

  programs.fish.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [ { inherit (config) type; } ];
  };

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

      extra-platforms = lib.mkIf stdenv.isDarwin [
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };
}
