# Custom packages. Consumed by flake.nix as `packages.<system>.*`.
# `pkgs` is a nixpkgs instance for the target system.
pkgs:
let
  claude-code = pkgs.callPackage ./claude-code/package.nix { };
in
{
  inherit claude-code;
  antigravity-cli = pkgs.callPackage ./antigravity-cli/package.nix { };
  claude-code-acp = pkgs.callPackage ./claude-code-acp/package.nix { inherit claude-code; };
  codex = pkgs.callPackage ./codex/package.nix { };
  codex-acp = pkgs.callPackage ./codex-acp/package.nix { };
  moshi-hook = pkgs.callPackage ./moshi-hook/package.nix { };
  executor = pkgs.callPackage ./executor/package.nix { };
}
