{
  description = ''
    github:huwaireb/System: Flaked System Configuration for MacOS
  '';

  outputs =
    inputs@{ nixpkgs, darwin, ... }:
    let
      lib = import ./lib {
        inherit inputs;
        lib = nixpkgs.lib.extend (_: _: darwin.lib);
      };
    in
    {
      darwinConfigurations.moon = import ./hosts/moon lib;
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig.experimental-features = "flakes nix-command pipe-operators";
}
