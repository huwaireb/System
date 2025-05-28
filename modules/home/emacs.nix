{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs) stdenv writeScript writeScriptBin;
  cfg = config.programs.emacs;
in
{
  xdg.configFile."emacs/early-init.el".text = lib.optionalString cfg.enable ''
    ;;; early-init.el --- Emacs Startup Options -*- lexical-binding: t -*-

    ;;; References:

    ;; https://github.com/sergeyklay/.emacs.d/blob/c1151116d027bec3a3912dc4ab7dc46627b23059/early-init.el
    ;; https://github.com/sjrmanning/.emacs.d/blob/9c3cfb94281231e487a1d5fb875568fcb297df92/early-init.el

    ;;; Code:

    ${lib.optionalString (lib.versionAtLeast cfg.package.version "31.0") ''
      ;; Make lexical binding the default early on
      (set-default-top-level-value 'lexical-binding t)
    ''}

    ;; Increasing the GC threshold is a common way to speed up Emacs.
    ;; `gc-cons-threshold' sets at what point Emacs should invoke its garbage
    ;; collector.  When set it temporarily to a large number, we only garbage
    ;; collect once on startup.  We'll reset it later, in this file.  Not
    ;; resetting it will cause stuttering/freezes.
    (setopt gc-cons-threshold most-positive-fixnum ; 2^61 bytes
            gc-cons-percentage 0.6)

    ;; Garbage Collector Optimization Hack
    (add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024) ; 16mb
                  gc-cons-percentage 0.1)))

    ;; The command-line option ‘-batch’ makes Emacs to run noninteractively.
    ;; In noninteractive sessions, prioritize non-byte-compiled source files to
    ;; prevent the use of stale byte-code.  Otherwise, skipping the mtime checks
    ;; on every *.elc file saves a bit of IO time.
    (setopt load-prefer-newer noninteractive)

    ;; Prevent the glimpse of un-styled Emacs by disabling these UI elements early.
    ${lib.optionalString (!stdenv.isDarwin) "(menu-bar-mode -1)"}
    (tool-bar-mode -1)
    (scroll-bar-mode -1)
    (blink-cursor-mode -1)

    ;; Contrary to common configurations, this is all that's needed to set UTF-8
    ;; as the default coding system:
    (set-language-environment "UTF-8")

    ;; `set-language-enviornment' sets `default-input-method', which is unwanted.
    (setopt default-input-method nil)

    ;; Reduce rendering/line scan work by not rendering cursors or regions in
    ;; non-focused windows.
    (setopt cursor-in-non-selected-windows nil)

    ;; Replace startup message with init-time.
    (fset 'display-startup-echo-area-message
          (lambda () (message (concat "Loaded config in " (emacs-init-time)))))

    ;; Load our modules
    (add-to-list 'load-path "${
      assert lib.assertMsg (lib.versionAtLeast cfg.package.version "29.0") "Requires emacs 29";
      ../emacs
    }") 
    ;; early-init.el ends here.
  '';

  programs.emacs.package = pkgs.emacs.overrideAttrs (o: {
    postInstall =
      let
        darwinIcon = pkgs.fetchurl {
          url = "https://github.com/SavchenkoValeriy/emacs-icons/raw/e6ac804a52600b607d9e8881a7f51ea2a3afe80a/curvy-blender/Emacs.icns";
          sha256 = "1phSRxzHEbK8vj7MdyYjYOKphb3JH0Wes4Y5yIOL7+4=";
        };
      in
      (o.postInstall or "")
      + lib.optionalString stdenv.isDarwin ''
        install -m644 ${darwinIcon} $out/Applications/Emacs.app/Contents/Resources/Emacs.icns
      '';
  });

  programs.emacs.extraPackages = e: [
    # Code
    e.apheleia
    e.envrc
    e.hl-todo
    e.markdown-mode
    e.nix-mode
    e.nix-ts-mode
    e.rust-mode
    e.swift-mode
    e.swift-ts-mode
    e.treesit-grammars.with-all-grammars
    e.zig-mode
    e.zig-ts-mode

    # Complete
    e.cape
    e.corfu
    e.orderless
    e.nerd-icons-corfu

    # Defaults
    e.exec-path-from-shell

    # Edit
    e.embark
    e.embark-consult
    e.git-link
    e.meow

    # Interface
    e.consult
    e.marginalia
    e.minions
    e.moody
    e.vertico

    # Version Control
    e.diff-hl
    e.magit

    # AI
    e.gptel
  ];

  services.emacs = {
    inherit (cfg) enable;
    # Get the Emacs icon on Darwin by executing the app located inside the bundle
    package =
      if stdenv.isDarwin then
        writeScriptBin "emacs" ''
          exec ${cfg.finalPackage}/Applications/Emacs.app/Contents/MacOS/Emacs "$@"
        ''
      else
        cfg.finalPackage;
  };

  home.sessionVariables.EDITOR = writeScript "emacsclient" ''${cfg.finalPackage}/bin/emacsclient -c "$@"'';
}
