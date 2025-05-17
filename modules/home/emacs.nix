{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) getBin;
  inherit (pkgs)
    emacs
    tree-sitter
    emacsPackages
    writeScript
    writeScriptBin
    ;

  final-emacs = config.programs.emacs.finalPackage;
in
{
  home.shellAliases.em = toString config.home.sessionVariables.EDITOR;
  home.sessionVariables.EDITOR = writeScript "emacsclient" ''exec emacsclient -c "$@"'';

  # HACK: We should be able to directly add treesit-grammars to extraPackages in programs.emacs
  xdg.configFile."emacs/tree-sitter".source =
    let
      tree-sitter-swift =
        let
          rev = "f67f569270ce8664a065313f1086a3484a3bec77";
        in
        tree-sitter.buildGrammar {
          language = "tree-sitter-swift";
          version = rev;
          generate = true;
          src = pkgs.fetchFromGitHub {
            owner = "alex-pinkus";
            repo = "tree-sitter-swift";
            inherit rev;
            sha256 = "p5xkQuOSYUuaiFWMvSsLCSEgAAYibfdbIUtNK4/X6V8=";
          };
        };

      grammars = emacsPackages.treesit-grammars.with-grammars (
        packaged: (builtins.attrValues packaged) ++ [ tree-sitter-swift ]
      );
    in
    "${grammars}/lib";

  xdg.configFile.emacs = {
    source = ./config/emacs;
    recursive = true;
  };

  services.emacs = {
    inherit (config.programs.emacs) enable;
    # NOTE: Not sure if it's any use, but I do get the Emacs icon with it when using emacsclient.
    package = writeScriptBin "emacs" ''exec ${final-emacs}/Applications/Emacs.app/Contents/MacOS/Emacs "$@"'';
  };

  programs.emacs = {
    enable = !config.isDarwin; # TODO: Re-enable when https://github.com/NixOS/nixpkgs/issues/395169 is resolved.
    package = emacs;

    extraConfig = "(setq nix-provides-packages t)";
    extraPackages =
      e: with e; [
        # editor.el
        consult
        marginalia
        embark
        embark-consult
        minions
        doom-themes
        magit
        diff-hl # VCS Gutter
        consult-todo
        exec-path-from-shell # Inherit nix environment

        # completion.el
        cape
        vertico
        corfu
        orderless

        # key.el
        meow

        # language.el
        envrc

        rust-mode
        typst-ts-mode

        nix-mode
        nix-ts-mode

        zig-mode
        zig-ts-mode

        swift-mode
        swift-ts-mode
      ];
  };
}
