;;; rm-code.el --- Programming Language Modes -*- lexical-binding: t -*-
(envrc-global-mode +1)    ; Load direnv when available
(global-eldoc-mode +1)    ; Documentation display
(global-hl-todo-mode +1)  ; Highlight TODOs.
(apheleia-global-mode +1) ; Auto Formatter

;; +eldoc
(setopt eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

;; +eglot
(setopt read-process-output-max (* 4 1024 1024) ; 4MB for LSP performance
        eglot-autoshutdown t                    ; Shutdown LSP server when done
        eglot-stay-out-of '(flymake)            ; Let Flymake handle diagnostics
        eglot-sync-connect nil)                 ; Don't wait for LSP to connect

(keymap-global-set "C-c a" 'eglot-code-actions)
(keymap-global-set "C-c r" 'eglot-rename)
(keymap-global-set "C-c k" 'eldoc)

(dolist (hook '(c-ts-mode-hook c++-ts-mode-hook rust-mode-hook nix-ts-mode-hook zig-ts-mode-hook))
  (add-hook hook 'eglot-ensure))

;; +treesit
(setopt treesit-font-lock-level 4      ; Maximum syntax highlighting level
        rust-mode-treesitter-derive t  ; Tell rust-mode to use treesit  
        major-mode-remap-alist '((c-mode . c-ts-mode)
                                 (sh-mode . bash-ts-mode)
                                 (c++-mode . c++-ts-mode)
                                 (nix-mode . nix-ts-mode)
                                 (zig-mode . zig-ts-mode)
                                 (python-mode . python-ts-mode)))

(derived-mode-add-parents 'zig-ts-mode '(zig-mode)) ; This should be upstream

;; +markdown
(setopt markdown-command "pandoc")

(with-eval-after-load 'markdown-mode
  (keymap-set markdown-mode-map "C-c C-e" 'markdown-do))

(add-to-list 'auto-mode-alist '("\\.\\(?:md\\|markdown\\|mkd\\|mdown\\|mkdn\\|mdwn\\)\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))

(provide 'rm-code)
;;; rm-code.el ends here
