;;; rm-interface.el --- User Interface Settings -*- lexical-binding: t -*-
(minions-mode +1)    ; Less messy modeline
(vertico-mode +1)    ; Vertical Completion UI
(which-key-mode +1)  ; Help UI For keybindings
(marginalia-mode +1) ; Margin Annotations
(global-display-line-numbers-mode +1)

;; Appearance
(load-theme 'modus-vivendi t)

(custom-set-faces
 '(fringe ((t (:background unspecified :foreground unspecified))))
 '(mode-line ((t (:background "#1A1A1A" :foreground "#FFFFFF" :box nil))))
 '(mode-line-inactive ((t (:background "#121212" :foreground "#A0A0A0" :box nil))))
 '(line-number ((t (:background unspecified :foreground "#666666"))))
 '(line-number-current-line ((t (:background unspecified :foreground "#999999")))))

;; Frame
(setopt scroll-margin 0
        scroll-conservatively 101
        ns-use-srgb-colorspace nil
        default-frame-alist   
        '((font . "Iosevka-18")
          (top . 77)            
          (left . 68)      
          (width . 147)
          (height . 37)
          (vertical-scroll-bars . nil)
          (horizontal-scroll-bars . nil)
          (ns-transparent-titlebar . t)
          (ns-appearance . dark)))

;; Title
(setopt ns-use-proxy-icon nil    ; Remove Icon
        icon-title-format "%b"   ; Buffer name as title
        frame-title-format "%b") ; ...

;; +vertico
(setopt vertico-cycle t
        vertico-resize t)

;; Modeline
(require 'moody)
(moody-replace-mode-line-front-space)
(moody-replace-mode-line-buffer-identification)
(moody-replace-vc-mode)

;; Line Numbers
(setopt display-line-numbers-type 'relative
        display-line-numbers-width 3
        display-line-numbers-widen t
        display-line-numbers-current-absolute t)

;; +consult 
(advice-add #'register-preview :override #'consult-register-window)
(setopt register-preview-delay 0.5
        xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref
        consult-narrow-key "<")

(with-eval-after-load 'consult
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-flymake consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   :preview-key '(:debounce 0.4 any)))

(keymap-global-set "C-c f" 'project-find-file)
(keymap-global-set "C-c F" 'consult-fd)
(keymap-global-set "C-c s" 'consult-imenu-multi)
(keymap-global-set "C-c b" 'consult-project-buffer)
(keymap-global-set "C-c B" 'consult-buffer)
(keymap-global-set "C-c j" 'consult-bookmark)
(keymap-global-set "C-c d" 'consult-flymake)
(keymap-global-set "C-c /" 'consult-ripgrep)

(add-hook 'embark-collect-mode-hook 'consult-preview-at-point-mode)  
(add-hook 'completion-list-mode-hook 'consult-preview-at-point-mode)

(provide 'rm-interface)
;;; rm-interface.el ends here
