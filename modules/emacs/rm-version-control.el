;;; rm-version-control.el --- Version Control Settings -*- lexical-binding: t -*-
;; Magit keybinding
(keymap-global-set "C-c v" 'magit)

;; Diff-hl configuration
(setopt diff-hl-fringe-bmp-function #'diff-hl-fringe-bmp-from-type
        diff-hl-draw-borders nil)

(autoload 'diff-hl-mode "diff-hl"
  "Diff Highlighting Mode" t)

(add-hook 'prog-mode-hook 'diff-hl-mode)
(add-hook 'conf-mode-hook 'diff-hl-mode)

(autoload 'diff-hl-dired-mode "diff-hl-dired"
  "Diff Highlighting Mode" t)

(add-hook 'dired-mode-hook 'diff-hl-dired-mode)

(autoload 'diff-hl-magit-post-refresh "diff-hl"
  "Diff Highlighting Mode" t)

(add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)

(provide 'rm-version-control)
;;; rm-version-control.el ends here
