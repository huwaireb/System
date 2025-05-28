;;; rm-defaults.el --- Default Emacs Settings -*- lexical-binding: t -*-
(savehist-mode +1) ; Persist minibuffer and command history across session

;; Suppress Insanity
(setopt ring-bell-function 'ignore ; Suppress audible bell
        use-dialog-box nil         ; Avoid GUI dialog boxes
        ns-pop-up-frames nil
        inhibit-startup-screen t)

;; Configuring file and buffer behavior
(setopt create-lockfiles nil  ; Useful only if you have multiple emacs sessions editing same file. Otherwise clutter.
        auto-save-default nil ; I periodically save, backups are enough.
        delete-by-moving-to-trash t)

;; Sane Backups
(setopt backup-directory-alist `(("." . ,(locate-user-emacs-file "backups")))
        vc-make-backup-files t ; Make backups even for files under version control
        version-control t      ; Enable versioned backups
        backup-by-copying t    ; Create backups by copying the file instead of renaming.
        kept-old-versions 0
        kept-new-versions 10
        delete-old-versions t)

;; Inherit environment from user shell, primarily for Nix
(when (or (daemonp) (memq window-system '(mac ns x)))          ; Only load when in daemon or window-system
  (setopt exec-path-from-shell-variables
          '("PATH" "MANPATH" "SSH_AUTH_SOCK" "SSH_AGENT_PID" "GPG_AGENT_INFO"
            "LANG" "LC_CTYPE" "NIX_SSL_CERT_FILE" "NIX_PATH")) ; Sync key shell variables
  (exec-path-from-shell-initialize))                           ; Initialize shell environment

(provide 'rm-defaults)
;;; rm-defaults.el ends here

