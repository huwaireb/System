;;; rm-version-control.el --- Version Control Settings -*- lexical-binding: t -*-
(require 'diff-hl)

;; Enable global modes
(global-diff-hl-mode +1) ; Git Gutter
(unless (window-system) (diff-hl-margin-mode +1)) 

;; Magit keybinding
(keymap-global-set "C-c v" 'magit)

;; Diff-hl configuration
(setopt diff-hl-side 'left
        diff-hl-draw-borders nil
        diff-hl-fringe-bmp-function 'diff-hl-fringe-bmp-from-pos)

(keymap-global-set "C-x v =" 'diff-hl-show-hunk)
(add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)

(provide 'rm-version-control)
;;; rm-version-control.el ends here
