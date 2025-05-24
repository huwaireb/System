;;; rm-defaults.el --- Default Emacs Settings -*- lexical-binding: t -*-
(require 'savehist) 

;; Enabling global modes
(savehist-mode +1) ; Persist minibuffer and command history across session

;; Configuring file and buffer behavior
(setopt create-lockfiles nil  ; Useful only if you have multiple emacs sessions editing same file. Otherwise clutter.
        auto-save-default nil ; I periodically save, backups are enough.
        delete-by-moving-to-trash t)

(setopt backup-directory-alist `(("." . ,(locate-user-emacs-file "backups")))
        vc-make-backup-files t ; Make backups even for files under version control
        version-control t      ; Enable versioned backups
        backup-by-copying t    ; Create backups by copying the file instead of renaming.
        kept-old-versions 0
        kept-new-versions 10
        delete-old-versions t)

;; Customizing user interface
(setopt ring-bell-function 'ignore      ; Suppress audible bell for quieter operation
        use-dialog-box nil              ; Avoid GUI dialog boxes
        inhibit-startup-screen t        ; Skip startup screen for faster launch
        )

;; Defining default frame appearance (TODO: Calculate almost maximum based on resolution)
(setopt default-frame-alist   
        '((font . "Iosevka-18")
          (top . 77)            
          (left . 68)      
          (width . 147)
          (height . 37)))  

;; Setting up shell environment integration
(when (or (daemonp) (memq window-system '(mac ns x)))          ; Only load when in daemon or window-system
  (require 'exec-path-from-shell)                              ; Load shell environment sync library
  (setopt exec-path-from-shell-variables
          '("PATH" "MANPATH" "SSH_AUTH_SOCK" "SSH_AGENT_PID" "GPG_AGENT_INFO"
            "LANG" "LC_CTYPE" "NIX_SSL_CERT_FILE" "NIX_PATH")) ; Sync key shell variables
  (exec-path-from-shell-initialize))                           ; Initialize shell environment

(provide 'rm-defaults)
;;; rm-defaults.el ends here

