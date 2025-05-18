;;; editor.el --- Emacs -*- lexical-binding: t -*-
;;

(use-package magit)

(use-package marginalia :hook (after-init . marginalia-mode))

(use-package savehist :ensure nil
  :hook (after-init . savehist-mode))

(use-package which-key :ensure nil
  :hook (after-init . which-key-mode))

(use-package emacs :ensure nil
  :custom
  (auto-save-default nil)
  (create-lockfiles nil)
  (ring-bell-function 'ignore)
  (use-dialog-box nil)
  (delete-by-moving-to-trash t)

  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  (read-extended-command-predicate #'command-completion-default-include-p)

  (default-frame-alist
   '((font . "Iosevka-18")
     ;; Almost Maximize
     (top . 77)
     (left . 68)
     (width . 150)
     (height . 39)))

  (display-line-numbers 'relative)
  (inhibit-startup-screen t)
  
  (mode-line-format
   '("%e" 
     mode-line-front-space
     (:eval (meow-indicator))
     " "
     (:propertize "%b" face (:foreground "cyan"))
     " "
     (vc-mode vc-mode)
     " "
     (:propertize mode-name face (:foreground "yellow"))
     mode-line-format-right-align
     (:propertize "%z" face (:foreground "green"))
     "|"
     (:propertize "%Z" face (:foreground "green"))
     "|"
     (:propertize "%c" face (:foreground "magenta"))
     "|"
     (:propertize "%p" face (:foreground "orange"))
     mode-line-end-spaces))
  :config
  (prefer-coding-system 'utf-8)
  (global-display-line-numbers-mode 'relative)
  
  (tool-bar-mode 0)
  (menu-bar-mode 0)
  (scroll-bar-mode 0)
  (blink-cursor-mode 0))

(use-package exec-path-from-shell
  :when (daemonp)
  :demand t
  :config
  (dolist (var '("SSH_AUTH_SOCK" "SSH_AGENT_PID" "GPG_AGENT_INFO" "LANG" "LC_CTYPE" "NIX_SSL_CERT_FILE" "NIX_PATH"))
    (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))

(use-package doom-themes
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  (load-theme 'doom-tokyo-night t))
	
(use-package consult
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :custom
  (register-preview-delay 0.5)
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref)
  (consult-narrow-key "<")
  :init
  (advice-add #'register-preview :override #'consult-register-window)
  :config
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-flymake consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   :preview-key '(:debounce 0.4 any)))

(use-package diff-hl
  :hook
  ((dired-mode . diff-hl-dired-mode)
   (prog-mode . diff-hl-mode)
   (conf-mode . diff-hl-mode)
   (magit-post-refresh . diff-hl-magit-post-refresh))
  :custom
  (diff-hl-fringe-bmp-function 'diff-hl-fringe-bmp-from-type)
  (diff-hl-draw-borders nil))

;; editor.el ends here
