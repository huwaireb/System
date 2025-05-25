;;; rm-version-control.el --- Version Control Settings -*- lexical-binding: t -*-
(global-diff-hl-mode +1) ; Git Gutter

;; +magit
(keymap-global-set "C-c v" 'magit) ; SPC v for shorter access when using Meow

;; +diff-hl
(custom-set-faces
 '(diff-hl-insert ((t (:background "#a6e3a1" :foreground "#a6e3a1"))))
 '(diff-hl-change ((t (:background "#f7e1a1" :foreground "#f7e1a1"))))
 '(diff-hl-delete ((t (:background "#f2b8b5" :foreground "#f2b8b5")))))

(setopt diff-hl-draw-borders nil
        diff-hl-fringe-bmp-function (lambda (type pos)
                                      (let* ((width 2)
                                             (bitmap (vector (1- (expt 2 width)))))
                                        (define-fringe-bitmap 'my:diff-hl-bitmap bitmap 1 width '(top t))
                                        'my:diff-hl-bitmap)))

(provide 'rm-version-control)
;;; rm-version-control.el ends here
