inputs@{
  nixpkgs,
  darwin,
  home-manager,
  ...
}:
let
  specialArgs = { inherit inputs; };
in
{
  nixosSystem' =
    module:
    nixpkgs.lib.nixosSystem {
      inherit specialArgs;
      modules = [
        module
        ../modules
        ../modules/nixos

        home-manager.nixosModules.home-manager
      ];
    };

  darwinSystem' =
    module:
    darwin.lib.darwinSystem {
      inherit specialArgs;
      modules = [
        module
        ../modules
        ../modules/darwin

        home-manager.darwinModules.home-manager
      ];
    };
}
