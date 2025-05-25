;;; rm-interface.el --- User Interface Settings -*- lexical-binding: t -*-
(require 'vertico)
(require 'marginalia)
(require 'which-key)
(require 'consult)
(require 'consult-flymake)
(require 'consult-xref)
(require 'embark)
(require 'embark-consult)

;; Appearance
(load-theme 'modus-vivendi t)

(custom-set-faces
 '(fringe ((t (:background nil :foreground nil))))
 '(line-number ((t (:background nil :foreground "#666666"))))
 '(line-number-current-line ((t (:background nil :foreground "#999999")))))

;; Enable global modes
(which-key-mode +1)
(marginalia-mode +1)
(global-display-line-numbers-mode +1)

;; Frame
(setopt default-frame-alist   
        '((font . "Iosevka-18")
          (top . 77)            
          (left . 68)      
          (width . 147)
          (height . 37)
          (ns-transparent-titlebar . t)
          (ns-appearance . dark)))

;; Title
(setopt ns-use-proxy-icon nil    ; Remove Icon
        icon-title-format "%b"   ; Buffer name as title
        frame-title-format "%b") ; ...

;; Line Numbers
(setopt display-line-numbers-type 'relative
        display-line-numbers-width 3
        display-line-numbers-widen t
        display-line-numbers-current-absolute t)

;; Vertico configuration
(setopt vertico-cycle t
        vertico-resize t)

(vertico-mode)

;; Consult configuration
(consult-customize
 consult-theme :preview-key '(:debounce 0.2 any)
 consult-ripgrep consult-git-grep consult-grep consult-man
 consult-bookmark consult-flymake consult-recent-file consult-xref
 consult--source-bookmark consult--source-file-register
 consult--source-recent-file consult--source-project-recent-file
 :preview-key '(:debounce 0.4 any))

(setopt register-preview-delay 0.5
        xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref
        consult-narrow-key "<")

(advice-add #'register-preview :override #'consult-register-window)
(add-hook 'completion-list-mode-hook #'consult-preview-at-point-mode)

;; Embark configuration
(setopt prefix-help-command #'embark-prefix-help-command)

(add-to-list 'display-buffer-alist
             '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
               nil
               (window-parameters (mode-line-format . none))))

(keymap-global-set "C-." 'embark-act)
(keymap-global-set "C-;" 'embark-dwim)
(keymap-global-set "C-h B" 'embark-bindings)

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
