;;; rm-defaults.el --- Default Emacs Settings -*- lexical-binding: t -*-
(require 'savehist) 

;; Enabling global modes
(savehist-mode +1) ; Persist minibuffer and command history across session

;; Configuring file and buffer behavior
(setopt auto-save-default nil        ; Disable auto-saving
        create-lockfiles nil         ; Prevent creation of lockfiles to avoid clutter
        delete-by-moving-to-trash t) ; Move deleted files to system trash

;; Customizing user interface
(setopt ring-bell-function 'ignore      ; Suppress audible bell for quieter operation
        use-dialog-box nil              ; Avoid GUI dialog boxes
        inhibit-startup-screen t        ; Skip startup screen for faster launch
        display-line-numbers 'relative) ; Show line numbers as relative

;; Defining default frame appearance
(setopt default-frame-alist   
        '((font . "Iosevka-18")
          (top . 77)            
          (left . 68)      
          (width . 147)
          (height . 37)))  

;; Setting up shell environment integration
(when (or (daemonp) (memq window-system '(mac ns x)))
  (require 'exec-path-from-shell)                              ; Load shell environment sync library
  (setopt exec-path-from-shell-variables
          '("PATH" "MANPATH" "SSH_AUTH_SOCK" "SSH_AGENT_PID" "GPG_AGENT_INFO"
            "LANG" "LC_CTYPE" "NIX_SSL_CERT_FILE" "NIX_PATH")) ; Sync key shell variables
  (exec-path-from-shell-initialize))                           ; Initialize shell environment

(provide 'rm-defaults)
;;; rm-defaults.el ends here

