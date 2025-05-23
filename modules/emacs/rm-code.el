;;; rm-code.el --- Programming Language Modes -*- lexical-binding: t -*-
(require 'envrc)
(require 'eldoc)
(require 'eglot)
(require 'treesit)
(require 'hl-todo)

;; Global modes
(envrc-global-mode 1)    ; Environment management
(global-eldoc-mode 1)    ; Documentation display
(global-hl-todo-mode 1)  ; Highlight TODOs

;; Eldoc configuration
(setopt eldoc-documentation-strategy #'eldoc-documentation-compose)

;; Eglot configuration
(setopt read-process-output-max (* 4 1024 1024)  ; 4MB for LSP performance
        eglot-autoshutdown t                     ; Shutdown LSP server when done
        eglot-stay-out-of '(flymake))            ; Let Flymake handle diagnostics

(keymap-global-set "C-c a" 'eglot-code-actions)
(keymap-global-set "C-c r" 'eglot-rename)
(keymap-global-set "C-c k" 'eldoc)

;; Treesit configuration
(setopt treesit-font-lock-level 4)  ; Maximum syntax highlighting level

;; Line Numbers
(with-eval-after-load 'prog-mode
  (add-hook 'prog-mode-hook 'display-line-numbers-mode))

;; Rust mode configuration
(autoload 'rust-mode "rust-mode"
  "Major mode for Rust programming" t)

(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

(with-eval-after-load 'rust-mode
  (add-hook 'rust-mode-hook 'eglot-ensure)
  (setopt rust-mode-treesitter-derive t))

;; Nix mode configuration
(autoload 'nix-ts-mode "nix-ts-mode"
  "Major mode for editing nix expressions" t)

(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-ts-mode))

(with-eval-after-load 'nix-ts-mode
  (add-hook 'nix-ts-mode-hook 'eglot-ensure))

;; Zig mode configuration
(autoload 'zig-ts-mode "zig-ts-mode"
  "Major mode for Zig programming" t)

(add-to-list 'auto-mode-alist '("\\.\\(zig\\|zon\\)\\'" . zig-ts-mode))

(with-eval-after-load 'zig-ts-mode
  (add-hook 'zig-ts-mode-hook 'eglot-ensure)
  (derived-mode-add-parents 'zig-ts-mode '(zig-mode)))

;; Objective-C mode configuration
(autoload 'objc-mode "objc-mode"
  "Major mode for Objective-C programming" t)

(add-to-list 'auto-mode-alist '("\\.m\\'" . objc-mode))

(with-eval-after-load 'objc-mode
  (add-hook 'objc-mode-hook 'eglot-ensure))

;; Markdown mode configuration
(setopt markdown-command "pandoc")

(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)

(add-to-list 'auto-mode-alist '("\\.\\(?:md\\|markdown\\|mkd\\|mdown\\|mkdn\\|mdwn\\)\\'" . markdown-mode))

(autoload 'gfm-mode "markdown-mode"
  "Major mode for editing GitHub Flavored Markdown files" t)

(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))

(with-eval-after-load 'markdown-mode
  (keymap-set markdown-mode-map "C-c C-e" 'markdown-do))

(provide 'rm-code)
;;; rm-code.el ends here
