;;; language.el --- PL Modes
;;

(use-package nix-ts-mode :mode "\\.nix\\'")

(use-package zig-mode :hook (zig-mode . lsp))
(use-package zig-ts-mode :mode "\\.zig\\'")

;;; language.el ends here
