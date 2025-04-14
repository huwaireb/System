{
  description = "huwaireb/system: Flaked System Configuration for MacOS & NixOS";

  outputs =
    inputs:
    inputs.parts.lib.mkFlake { inherit inputs; } {
      flake.darwinConfigurations.mbp23 = inputs.darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit (inputs) self; };
        modules = [
          inputs.home-manager.darwinModules.home-manager

          ./hosts/mbp23
          ./modules/system._
          ./modules/system.darwin

          ./settings.nix
        ];
      };

      imports = [ ./firmware ];
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
