{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";

  inputs.zephyr = {
    url = "github:zmkfirmware/zephyr/v3.5.0+zmk-fixes";
    flake = false;
  };

  inputs.zmk = {
    url = "github:zmkfirmware/zmk";
    flake = false;
  };

  outputs =
    inputs:
    { nixpkgs, systems, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      packages =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          adv360 = pkgs.callPackage ./adv360 { inherit inputs; };
        }
        |> eachSystem;
    };

  nixConfig.experimental-features = [
    "flakes"
    "nix-command"
    "pipe-operators"
  ];
}
