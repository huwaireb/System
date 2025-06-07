;;; rm-code.el --- Programming Language Modes -*- lexical-binding: t -*-
(envrc-global-mode +1)    ; Load direnv when available
(global-eldoc-mode +1)    ; Documentation display
(editorconfig-mode +1)    ; Respect .editorconfig by default
(global-hl-todo-mode +1)  ; Highlight TODOs.
(apheleia-global-mode +1) ; Auto Formatter

;; +eldoc
(setopt eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

;; +markdown
(setopt markdown-command "pandoc")

(with-eval-after-load 'markdown-mode
  (keymap-set markdown-mode-map "C-c C-e" 'markdown-do))

(add-to-list 'auto-mode-alist '("\\.\\(?:md\\|markdown\\|mkd\\|mdown\\|mkdn\\|mdwn\\)\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))

;; +buck2
(define-derived-mode buck2-mode python-mode "Buck2"
  "Major mode for editing Buck2 build files (BUCK, .bzl, .star, PACKAGE)")

(add-to-list 'auto-mode-alist '("\\(?:BUCK\\|PACKAGE\\|\\.bzl\\|\\.star\\)\\'" . buck2-mode))

;; +eglot
(setopt read-process-output-max (* 4 1024 1024) ; 4MB for LSP performance
        eglot-autoshutdown t                    ; Shutdown LSP server when done
        eglot-sync-connect nil)                 ; Don't wait for LSP to connect

(keymap-global-set "C-c a" 'eglot-code-actions)
(keymap-global-set "C-c r" 'eglot-rename)
(keymap-global-set "C-c k" 'eldoc)

(dolist (hook '(buck2-mode-hook c-ts-mode-hook c++-ts-mode-hook nix-ts-mode-hook
                                rust-mode-hook swift-mode-hook typst-ts-mode zig-ts-mode-hook))
  (add-hook hook 'eglot-ensure))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '(buck2-mode . ("buck2" "lsp")))
  (add-to-list 'eglot-server-programs '(swift-mode . ("sourcekit-lsp")))
  (add-to-list 'eglot-server-programs '(typst-ts-mode . ("tinymist" "lsp"))))

;; +treesit
(setopt treesit-font-lock-level 4      ; Maximum syntax highlighting level
        rust-mode-treesitter-derive t  ; Tell rust-mode to use treesit  
        major-mode-remap-alist '((c-mode . c-ts-mode)
                                 (sh-mode . bash-ts-mode)
                                 (c++-mode . c++-ts-mode)
                                 (nix-mode . nix-ts-mode)
                                 (zig-mode . zig-ts-mode)
                                 (python-mode . python-ts-mode)))

;; These should be upstream
(derived-mode-add-parents 'zig-ts-mode '(zig-mode))

;; +apheleia
(with-eval-after-load 'apheleia
  (add-to-list 'apheleia-formatters '(swift-format . ("swift-format" "-")))
  (add-to-list 'apheleia-mode-alist '(swift-mode . swift-format)))

(provide 'rm-code)
;;; rm-code.el ends here
