{ pkgs, ... }:
let
  package = pkgs.emacs;
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
        zig-mode
        zig-ts-mode
      ];
  };

  home.sessionVariables.EDITOR = pkgs.writeScriptBin "emacsclient" ''
    emacsclient -c -a "" "$@"
  '';
}
