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

    linux-builder = lib.mkIf stdenv.isDarwin {
      enable = false;
      ephemeral = true;
      systems = [ "aarch64-linux" ];
      supportedFeatures = [
        "benchmark"
        "kvm"
        "big-parallel"
        "nixos-test"
      ];

      config.virtualisation = {
        cores = 8;
        darwin-builder.diskSize = 100 * 1024;
        darwin-builder.memorySize = 8 * 1024;
      };
    };

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
        "@wheel"
        "@admin"
      ];
    };
  };

  launchd.daemons.linux-builder = lib.mkIf stdenv.isDarwin {
    serviceConfig = {
      StandardOutPath = "/var/log/darwin-builder.log";
      StandardErrorPath = "/var/log/darwin-builder.log";
    };
  };
}
