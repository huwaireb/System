inputs@{
  self,
  nixpkgs,
  darwin,
  home-manager,
  nix-ld,
  ...
}:
let
  specialArgs = { inherit inputs self; };
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

        nix-ld.nixosModules.nix-ld
        home-manager.nixosModules.home-manager

        { home-manager.extraSpecialArgs = specialArgs; }
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

        { home-manager.extraSpecialArgs = specialArgs; }
      ];
    };
}
