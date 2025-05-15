;;; completion.el --- Completions
;;

(use-package dabbrev
  ;; Swap M-/ and C-M-/
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand))
  :custom
  (dabbrev-ignored-buffer-modes
   (append dabbrev-ignored-buffer-modes
	   '(authinfo-mode doc-view-mode pdf-view-mode tags-table-mode)))
  :config
  (add-to-list 'dabbrev-ignored-buffer-regexps "\\` "))

(use-package vertico
  :custom
  (vertico-cycle t)
  (vertico-resize t)
  :init
  (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package corfu
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.2)  
  :init
  (global-corfu-mode)
  (corfu-history-mode))

(use-package cape
  :bind ("C-c p" . cape-prefix-map)
  :init
  (dolist (fn '(cape-dabbrev cape-file cape-elisp-symbol cape-keyword cape-dict))
    (add-hook 'completion-at-point-functions fn)))

;; completion.el ends here
