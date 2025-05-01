{
  description = ''
    github:huwaireb/System: Flaked System Configuration for MacOS & NixOS
  '';

  outputs =
    inputs@{ nixpkgs, darwin, ... }:
    let
      inherit (builtins) groupBy readDir listToAttrs;
      inherit (nixpkgs.lib) filterAttrs mapAttrs attrsToList;

      lib' = import ./lib {
        inherit inputs;
        lib = nixpkgs.lib.extend (_: _: darwin.lib);
      };

      hosts =
        readDir ./hosts
        |> filterAttrs (_: type: type == "directory")
        |> mapAttrs (host: _: import ./hosts/${host} lib')
        |> attrsToList
        |> groupBy (
          { value, ... }:
          let
            class0 = fail: if value.class == "nixos" then "nixosConfigurations" else fail;
            class1 = fail: if value.class == "darwin" then "darwinConfigurations" else fail;
            classFail = throw "unreachable: The class of the system is unhandled (flake.nix)";
          in
          class0 (class1 classFail)
        )
        |> mapAttrs (_: v: listToAttrs v);
    in
    hosts // { };

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

  nixConfig.experimental-features = [
    "flakes"
    "nix-command"
    "pipe-operators"
  ];
}
