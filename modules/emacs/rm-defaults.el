;;; rm-defaults.el --- Default Emacs Settings -*- lexical-binding: t -*-
(require 'savehist)
(require 'exec-path-from-shell)

;; General Emacs settings
(setopt auto-save-default nil
        create-lockfiles nil
        ring-bell-function 'ignore
        use-dialog-box nil
        delete-by-moving-to-trash t
        tab-always-indent 'complete
        text-mode-ispell-word-completion nil
        read-extended-command-predicate #'command-completion-default-include-p
        default-frame-alist '((font . "Iosevka-18")
                             (top . 77)
                             (left . 68)
                             (width . 150)
                             (height . 39))
        display-line-numbers 'relative
        inhibit-startup-screen t)

(global-display-line-numbers-mode 1)

;; Comment keybinding
(keymap-global-set "C-c c" 'comment-dwim)

;; Savehist configuration
(savehist-mode 1)

;; Exec-path-from-shell configuration
(dolist (var '("SSH_AUTH_SOCK" "SSH_AGENT_PID" "GPG_AGENT_INFO" "LANG" "LC_CTYPE" "NIX_SSL_CERT_FILE" "NIX_PATH"))
  (add-to-list 'exec-path-from-shell-variables var))
(exec-path-from-shell-initialize)

(provide 'rm-defaults)
;;; rm-defaults.el ends here
