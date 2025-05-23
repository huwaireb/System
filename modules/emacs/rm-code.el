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

;; Eglot keybindings
(global-set-key (kbd "C-c a") #'eglot-code-actions)
(global-set-key (kbd "C-c r") #'eglot-rename)
(global-set-key (kbd "C-c k") #'eldoc)

;; Treesit configuration
(unless (treesit-available-p)
  (error "Tree-sitter support is required but not available in this Emacs build"))

(setopt treesit-font-lock-level 4)  ; Maximum syntax highlighting level

;; Line Numbers
(with-eval-after-load 'prog-mode
  (add-hook 'prog-mode-hook 'display-line-numbers-mode))

;; File associations for programming modes
(dolist (assoc '(("\\.rs\\'" . rust-mode)
                 ("\\.nix\\'" . nix-ts-mode)
                 ("\\.zig\\'" . zig-ts-mode)
                 ("\\.zon\\'" . zig-ts-mode)
                 ("\\.m\\'" . objc-mode)))
  (add-to-list 'auto-mode-alist assoc))

;; Rust mode configuration
(with-eval-after-load 'rust-mode
  (add-hook 'rust-mode-hook 'eglot-ensure)
  (setopt rust-mode-treesitter-derive t))

;; Nix mode configuration
(with-eval-after-load 'nix-ts-mode
  (add-hook 'nix-ts-mode-hook 'eglot-ensure))

;; Zig mode configuration
(with-eval-after-load 'zig-ts-mode
  (add-hook 'zig-ts-mode-hook 'eglot-ensure)
  (derived-mode-add-parents 'zig-ts-mode '(zig-mode)))

;; Objective-C mode configuration
(with-eval-after-load 'objc-mode
  (add-hook 'objc-mode-hook 'eglot-ensure))

(provide 'rm-code)
;;; rm-code.el ends here
