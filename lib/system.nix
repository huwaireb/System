{ lib, inputs, ... }:
let
  specialArgs = { inherit inputs; };
in
{
  nixosSystem' =
    module:
    lib.nixosSystem {
      inherit specialArgs;
      modules = [
        module
        ../modules
        ../modules/nixos

        inputs.home-manager.nixosModules.home-manager
      ];
    };

  darwinSystem' =
    module:
    inputs.darwin.lib.darwinSystem {
      inherit specialArgs;
      modules = [
        module
        ../modules
        ../modules/darwin

        inputs.home-manager.darwinModules.home-manager
      ];
    };
}
