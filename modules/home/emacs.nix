{ lib, pkgs, ... }:
let
  package = pkgs.emacs;
  inherit (lib) getExe;
in
{
  services.emacs = {
    enable = true;
    inherit package;
  };

  programs.emacs = {
    enable = true;
    inherit package;

    extraPackages =
      e: with e; [
        magit
        doom-themes
        vertico
        consult
        orderless
        
        meow

        zig-mode
        zig-ts-mode

        nix-mode
        nix-ts-mode
      ];
  };

  home.shellAliases.ec = "$EDITOR";
  home.sessionVariables.EDITOR = getExe (pkgs.writeScriptBin "emacsclient" ''
    emacsclient -c -a "" "$@"
  '');
}
