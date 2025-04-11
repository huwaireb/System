{
  description = "huwaireb/system: Flaked System Configuration for MacOS & NixOS";

  outputs =
    inputs@{
      self,
      darwin,
      parts,
      ...
    }:
    parts.lib.mkFlake { inherit inputs; } {
      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt-rfc-style;
        };

      flake.darwinConfigurations.mbp23 = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit self inputs;
        };
        modules = [
          inputs.home-manager.darwinModules.home-manager

          ./hosts/mbp23
          ./modules/system._
          ./modules/system.darwin

          ./settings.nix
        ];
      };

      imports = [ ./lib ];
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
      ];
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
