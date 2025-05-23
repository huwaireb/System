;;; rm-interface.el --- User Interface Settings -*- lexical-binding: t -*-
(require 'vertico)
(require 'marginalia)
(require 'which-key)
(require 'consult)
(require 'consult-flymake)
(require 'consult-xref)
(require 'embark)
(require 'embark-consult)

;; Vertico configuration
(setopt vertico-cycle t
        vertico-resize t)
(vertico-mode)

;; Marginalia configuration
(add-hook 'after-init-hook #'marginalia-mode)

;; Which-key configuration
(add-hook 'after-init-hook #'which-key-mode)

;; Doom-themes configuration
(load-theme 'modus-vivendi t)

;; Consult configuration
(add-hook 'completion-list-mode-hook #'consult-preview-at-point-mode)
(setopt register-preview-delay 0.5
        xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref
        consult-narrow-key "<")
(advice-add #'register-preview :override #'consult-register-window)
(consult-customize
 consult-theme :preview-key '(:debounce 0.2 any)
 consult-ripgrep consult-git-grep consult-grep consult-man
 consult-bookmark consult-flymake consult-recent-file consult-xref
 consult--source-bookmark consult--source-file-register
 consult--source-recent-file consult--source-project-recent-file
 :preview-key '(:debounce 0.4 any))

;; Embark configuration
(global-set-key (kbd "C-.") #'embark-act)
(global-set-key (kbd "C-;") #'embark-dwim)
(global-set-key (kbd "C-h B") #'embark-bindings)
(setopt prefix-help-command #'embark-prefix-help-command)
(add-to-list 'display-buffer-alist
             '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
               nil
               (window-parameters (mode-line-format . none))))

;; Embark-consult configuration
(add-hook 'embark-collect-mode-hook #'consult-preview-at-point-mode)

;; Consult keybindings
(keymap-global-set "C-c f" 'project-find-file)
(keymap-global-set "C-c F" 'consult-fd)
(keymap-global-set "C-c s" 'consult-imenu-multi)
(keymap-global-set "C-c b" 'consult-project-buffer)
(keymap-global-set "C-c B" 'consult-buffer)
(keymap-global-set "C-c j" 'consult-bookmark)
(keymap-global-set "C-c d" 'consult-flymake)
(keymap-global-set "C-c /" 'consult-ripgrep)

(provide 'rm-interface)
;;; rm-interface.el ends here
