;;; rm-complete.el --- Completion Settings -*- lexical-binding: t -*-
(require 'dabbrev)
(require 'orderless)
(require 'corfu)
(require 'corfu-history)

;; Enable global modes
(global-corfu-mode +1)

;; Dabbrev configuration
(keymap-global-set "M-/" 'dabbrev-completion)
(keymap-global-set "C-M-/" 'dabbrev-expand)
(add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
(setopt dabbrev-ignored-buffer-modes
        '(authinfo-mode doc-view-mode pdf-view-mode tags-table-mode))

;; Orderless configuration
(setopt completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion))))

;; Corfu configuration
(setopt corfu-min-width 32
        corfu-max-width 80
        corfu-count 10
        corfu-scroll-margin 2
        corfu-cycle t
        corfu-auto t
        corfu-auto-prefix 2
        corfu-auto-delay 0.2)

(corfu-history-mode)
(add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)

;; Corfu keybindings
(keymap-set corfu-map "C-n" #'corfu-next)
(keymap-set corfu-map "C-p" #'corfu-previous)
(keymap-set corfu-map "<return>" #'corfu-insert)
(keymap-set corfu-map "<escape>" #'corfu-quit)
(keymap-set corfu-map "M-d" #'corfu-info-documentation)
(keymap-set corfu-map "M-l" #'corfu-info-location)
(keymap-set corfu-map "M-n" #'corfu-popupinfo-scroll-up)
(keymap-set corfu-map "M-p" #'corfu-popupinfo-scroll-down)

;; Cape configuration
(keymap-global-set "C-c p" 'cape-prefix-map)

(defun rm/setup-cape-completions ()
  (dolist (fn '(cape-dabbrev cape-file cape-elisp-symbol cape-keyword))
    (add-hook 'completion-at-point-functions fn)))

(add-hook 'prog-mode-hook #'rm/setup-cape-completions)
(add-hook 'text-mode-hook #'rm/setup-cape-completions)

(provide 'rm-complete)
;;; rm-complete.el ends here
