{
  nixConfig = {
    flake-registry = "";

    show-trace = true;
    lazy-trees = true;
    warn-dirty = false;

    experimental-features = [
      "flakes"
      "nix-command"
      "pipe-operators"
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      lib = import ./lib inputs;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: import ./packages pkgs);

      darwinConfigurations.moon = lib.darwinSystem' {
        type = "desktop";
        imports = [ ./hosts/moon ];
      };

      nixosConfigurations.triton = lib.nixosSystem' {
        type = "desktop";
        imports = [ ./hosts/triton ];
      };

      nixosConfigurations.carbon = lib.nixosSystem' {
        type = "desktop";
        imports = [ ./hosts/carbon ];
      };
    };
}
