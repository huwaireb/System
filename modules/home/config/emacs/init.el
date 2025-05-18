;;; init.el --- Config Entrypoint -*- lexical-binding: t -*-
;;

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s seconds with %d garbage collections."
                     (emacs-init-time "%.2f")
                     gcs-done)))

(defvar nix-provides-packages nil
  "Flag to check if nix provides packages; set in programs.emacs.extraConfig")

(unless nix-provides-packages
  (defvar packages-refreshed nil
    "Flag for whether package lists have been refreshed yet.")

  (setopt package-install-upgrade-built-in t
	  package-archives '(("melpa" . "https://melpa.org/packages/")
			     ("elpa" . "https://elpa.gnu.org/packages/")))

  (defun my/package-refresh (&rest args)
    "Refresh package metadata, if needed. Ignores `ARGS'."
    (unless (eq packages-refreshed t)
      (progn
	(package-refresh-contents t)
	(setq packages-refreshed t))))

  (advice-add 'package-install :before #'my/package-refresh)

  (package-initialize))

(require 'use-package)
(setopt use-package-always-ensure (not nix-provides-packages))

(defun load-rel (path)
  "Load an Emacs Lisp file relative to the current file."
  (progn
    (message "Loading file %s..." path)
    (load (expand-file-name path (file-name-directory (or load-file-name buffer-file-name))))))

(use-package server :ensure nil
  :defer 1
  :config
  (unless (server-running-p) (server-start)))

(load-rel "editor.el")
(load-rel "key.el")
(load-rel "completion.el")
(load-rel "language.el")

;; init.el ends here
