;;; rm-complete.el --- Completion Settings -*- lexical-binding: t -*-
(require 'dabbrev)
(require 'orderless)
(require 'corfu)
(require 'corfu-history)
(require 'cape)

;; Dabbrev configuration
(global-set-key (kbd "M-/") #'dabbrev-completion)
(global-set-key (kbd "C-M-/") #'dabbrev-expand)
(add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
(dolist (mode '(authinfo-mode doc-view-mode pdf-view-mode tags-table-mode))
  (add-to-list 'dabbrev-ignored-buffer-modes mode))

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

;; Cape configuration
(global-set-key (kbd "C-c p") #'cape-prefix-map)
(dolist (fn '(cape-dabbrev cape-file cape-elisp-symbol cape-keyword))
  (add-hook 'completion-at-point-functions fn))

(provide 'rm-complete)
;;; rm-complete.el ends here
