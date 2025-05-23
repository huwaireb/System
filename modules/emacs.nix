{ config, pkgs, ... }:
let
  inherit (pkgs) writeScript;
  cfg = config.programs.emacs;
in
{
  xdg.configFile."emacs/early-init.el".text = ''
    ;;; early-init.el --- Emacs Startup Options -*- lexical-binding: t -*-

    ;;; References:

    ;; https://github.com/sergeyklay/.emacs.d/blob/c1151116d027bec3a3912dc4ab7dc46627b23059/early-init.el
    ;; https://github.com/sjrmanning/.emacs.d/blob/9c3cfb94281231e487a1d5fb875568fcb297df92/early-init.el

    ;;; Code:

    ;; Make lexical binding the default early on (Requires Emacs 31)
    ;; (set-default-top-level-value 'lexical-binding t)

    ;; Increasing the GC threshold is a common way to speed up Emacs.
    ;; `gc-cons-threshold' sets at what point Emacs should invoke its garbage
    ;; collector.  When set it temporarily to a large number, we only garbage
    ;; collect once on startup.  We'll reset it later, in this file.  Not
    ;; resetting it will cause stuttering/freezes.
    (setopt gc-cons-threshold most-positive-fixnum ; 2^61 bytes
          gc-cons-percentage 0.6)

    ;; The command-line option ‘-batch’ makes Emacs to run noninteractively.
    ;; In noninteractive sessions, prioritize non-byte-compiled source files to
    ;; prevent the use of stale byte-code.  Otherwise, skipping the mtime checks
    ;; on every *.elc file saves a bit of IO time.
    (setopt load-prefer-newer noninteractive)

    ;; Prevent the glimpse of un-styled Emacs by disabling these UI elements early.
    (menu-bar-mode 0)
    (tool-bar-mode 0)
    (scroll-bar-mode 0)
    (blink-cursor-mode 0)

    ;; Contrary to common configurations, this is all that's needed to set UTF-8
    ;; as the default coding system:
    (set-language-environment "UTF-8")

    ;; `set-language-enviornment' sets `default-input-method', which is unwanted.
    (setopt default-input-method nil)

    ;; Reduce rendering/line scan work by not rendering cursors or regions in
    ;; non-focused windows.
    (setopt cursor-in-non-selected-windows nil)

    ;; Prevent Emacs from automatically initializing packages at startup.  This
    ;; allows the main init file to handle package initialization manually,
    ;; providing more control over when and how packages are loaded.
    ;;(setopt package-enable-at-startup nil)

    ;; Replace startup message with init-time.
    (fset 'display-startup-echo-area-message
          (lambda () (message (concat "Loaded config in " (emacs-init-time)))))

    (add-to-list 'load-path "${./emacs}")
    ;; early-init.el ends here.
  '';

  programs.emacs.extraPackages = e: [
    # Interface
    e.consult
    e.marginalia
    e.embark
    e.embark-consult
    e.vertico

    # Version Control
    e.magit
    e.diff-hl

    # Defaults
    e.exec-path-from-shell

    # Complete
    e.cape
    e.corfu
    e.orderless

    # Edit
    e.meow

    # Code
    e.envrc
    e.hl-todo
    e.rust-mode
    e.nix-mode
    e.nix-ts-mode
    e.zig-mode
    e.zig-ts-mode
    e.swift-mode
    e.swift-ts-mode
    e.markdown-mode
    e.treesit-grammars.with-all-grammars
  ];

  services.emacs = { inherit (cfg) enable; };
  home.sessionVariables.EDITOR = writeScript "emacsclient" ''${cfg.finalPackage}/bin/emacsclient -c "$@"'';
}
