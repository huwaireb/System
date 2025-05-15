{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.darwin = {
    url = "github:LnL7/nix-darwin";
    inputs.nixpkgs.follows = "nixpkgs";
  };
 
  outputs =
    inputs:
    let
      lib = import ./lib inputs;
    in {
      darwinConfigurations.moon = import ./hosts/moon lib;
    };

  nixConfig.experimental-features = [
    "flakes"
    "nix-command"
    "pipe-operators"
  ];
}
