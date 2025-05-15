;;; language.el --- PL Modes
;;

(use-package envrc
  :hook (after-init . envrc-global-mode))

(use-package rust-mode
  :mode "\\.rs\\'"
  :hook (rust-mode . eglot-ensure)
  :custom
  (rust-mode-treesitter-derive t))

(use-package nix-mode)
(use-package nix-ts-mode
  :mode "\\.nix\\'"
  :hook (nix-ts-mode . eglot-ensure))

(use-package zig-mode)
(use-package zig-ts-mode
  :mode (("\\.zig\\'" . zig-ts-mode)
	 ("\\.zon\\'" . zig-ts-mode))
  :hook (zig-ts-mode . eglot-ensure)
  :config
  ;; upstream should derive
  (derived-mode-add-parents 'zig-ts-mode '(zig-mode)))

(use-package eglot
  :custom
  (eglot-autoshutdown t)
  (eglot-stay-out-of '(flymake))
  :config
  (setq read-process-output-max (* 4 1024 1024)))

(use-package treesit
  :when (treesit-available-p)
  :custom (treesit-font-lock-level 4))

(use-package hl-todo
  :config
  (global-hl-todo-mode))

;; language.el ends here
