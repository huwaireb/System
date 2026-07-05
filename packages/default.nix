# Custom packages. Consumed by flake.nix as `packages.<system>.*`.
# `pkgs` is a nixpkgs instance for the target system.
pkgs: {
  moshi-hook = pkgs.callPackage ./moshi-hook/package.nix { };
}
