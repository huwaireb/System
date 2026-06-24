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

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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

      nixosConfigurations.triton = lib.nixosSystem' {
        type = "desktop";
        imports = [ ./hosts/triton ];
      };

      nixosConfigurations.carbon = lib.nixosSystem' {
        type = "desktop";
        imports = [ ./hosts/triton ];
      };
    };
}
