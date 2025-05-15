;;; init.el --- Config Entrypoint -*- lexical-binding: t -*-
;;

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s seconds with %d garbage collections."
                     (emacs-init-time "%.2f")
                     gcs-done)))

(require 'use-package)
(setq use-package-always-ensure nil) ;; Nix provides packages

(defun load-rel (path)
  "Load an Emacs Lisp file relative to the current file."
  (progn
    (message "Loading file %s..." path)
    (load (expand-file-name path (file-name-directory (or load-file-name buffer-file-name))))))
 
(load-rel "editor.el")
(load-rel "key.el")
(load-rel "completion.el")
(load-rel "language.el")

;; init.el ends here
