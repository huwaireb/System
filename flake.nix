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
    nix.url = "github:DeterminateSystems/nix-src";
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
    inputs:
    let
      lib = import ./lib inputs;
    in
    {
      darwinConfigurations.moon = lib.darwinSystem' {
        type = "desktop";
        imports = [ ./hosts/moon ];
      };
    };
}
