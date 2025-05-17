;; -*- lexical-binding: t -*-

(set-default-toplevel-value 'lexical-binding t)

(setq
 site-run-file nil       ; No site-wide run-time initializations. 
 inhibit-default-init t) ; No site-wide default library

(setq native-comp-eln-load-path
      (list (expand-file-name "eln-cache" user-emacs-directory)))

;; Set a reasonable garbage-collection threshold, ~52 MB
(add-hook 'after-init-hook
          #'(lambda () (setopt gc-cons-threshold (* 50 1024 1024))))
