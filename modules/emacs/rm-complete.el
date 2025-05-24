;;; rm-complete.el --- Completion Settings -*- lexical-binding: t -*-
(require 'dabbrev)
(require 'orderless)
(require 'corfu)
(require 'corfu-history)
(require 'cape)

;; Dabbrev configuration
(keymap-global-set "M-/" 'dabbrev-completion)
(keymap-global-set "C-M-/" 'dabbrev-expand)
(add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
(setopt dabbrev-ignored-buffer-modes
        '(authinfo-mode doc-view-mode pdf-view-mode tags-table-mode))

;; Orderless configuration
(setopt completion-styles '(orderless flex)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion))))

;; Corfu configuration
(setopt corfu-cycle t
        corfu-auto t
        corfu-auto-prefix 2
        corfu-auto-delay 0.2)
(global-corfu-mode)
(corfu-history-mode)
(corfu-popupinfo-mode)

;; Cape configuration
(keymap-global-set "C-c p" 'cape-prefix-map)

(defun rm/setup-cape-completions ()
    (dolist (fn '(cape-dabbrev cape-file cape-elisp-symbol cape-keyword))
      (add-hook 'completion-at-point-functions fn)))

(add-hook 'prog-mode-hook #'rm/setup-cape-completions)
(add-hook 'text-mode-hook #'rm/setup-cape-completions)

(provide 'rm-complete)
;;; rm-complete.el ends here
