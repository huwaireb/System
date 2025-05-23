;;; rm-version-control.el --- Version Control Settings -*- lexical-binding: t -*-

(require 'magit)
(require 'diff-hl)

;; Magit keybinding
(global-set-key (kbd "C-c v") #'magit)

;; Diff-hl configuration
(add-hook 'dired-mode-hook #'diff-hl-dired-mode)
(add-hook 'prog-mode-hook #'diff-hl-mode)
(add-hook 'conf-mode-hook #'diff-hl-mode)
(add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)
(setopt diff-hl-fringe-bmp-function #'diff-hl-fringe-bmp-from-type
        diff-hl-draw-borders nil)

(provide 'rm-version-control)
;;; rm-version-control.el ends here
