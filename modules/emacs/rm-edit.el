;;; rm-edit.el --- Keybindings for Editing -*- lexical-binding: t -*-
(require 'meow)
(require 'windmove)

;; Enabling global modes
(meow-global-mode +1)        ; Modal Editing
(electric-pair-mode +1)      ; Matching pairs
(delete-selection-mode +1)   ; Delete selected text on typing
(global-auto-revert-mode +1) ; Revert file when out-of-sync

;; Sane Opts
(setopt tab-width 3
        standard-indent 3
        tab-always-indent 'complete                                             ; Complete if indented
        indent-tabs-mode nil                                                    ; Don't use tabs for indent
        text-mode-ispell-word-completion nil                                    ; Disable ispell completion in text mode
        read-extended-command-predicate #'command-completion-default-include-p) ; Filter M-x commands

;; Window Management Keybindings
(defun rm/split-window-below ()
  (interactive)
  (select-window (split-window-below)))

(defun rm/split-window-right ()
  (interactive)
  (select-window (split-window-right)))

(defvar-keymap rm/window-map
  :doc "Window manipulation keymap inspired by Helix"
  "w" #'other-window
  "s" #'rm/split-window-below
  "v" #'rm/split-window-right
  "q" #'delete-window
  "o" #'delete-other-windows
  "h" #'windmove-left
  "n" #'windmove-down
  "e" #'windmove-up
  "i" #'windmove-right
  "H" #'windmove-swap-states-left
  "N" #'windmove-swap-states-down
  "E" #'windmove-swap-states-up
  "I" #'windmove-swap-states-right)

(keymap-global-set "C-c w" rm/window-map)

;; Meow Modal Editing Keybindings
(meow--enable-shims) ; Enable shims to better work with packages like magit, eldoc, corfu etc

(defun rm/meow-redo ()
  "Cancel current selection then redo using Emacs' undo-redo."
  (interactive)
  (when (region-active-p)
    (meow--cancel-selection))
  (undo-redo))

(defun rm/meow-bind-digit-arguments (keymap)
  "Bind digits 0-9 to meow-digit-argument in KEYMAP."
  (dolist (digit '("0" "1" "2" "3" "4" "5" "6" "7" "8" "9"))
    (funcall keymap digit #'meow-digit-argument)))

;; Motion bindings
(meow-motion-define-key
 '("e" . meow-prev)
 '("<escape>" . ignore))

;; Leader keybindings
(meow-leader-define-key
 '("?" . meow-M-x)
 '("y" . meow-clipboard-save)
 '("p" . meow-clipboard-yank)
 '("c" . comment-dwim))
(rm/meow-bind-digit-arguments #'meow-leader-define-key)

;; Normal mode keybindings
(meow-normal-define-key
 '("-" . negative-argument)
 '(";" . meow-reverse))
(rm/meow-bind-digit-arguments #'meow-normal-define-key)

;; Movement
(meow-normal-define-key
 '("h" . meow-left)
 '("i" . meow-right)
 '("n" . meow-next)
 '("e" . meow-prev)
 '("w" . meow-next-word)
 '("b" . meow-back-word)
 '("W" . meow-next-symbol)
 '("B" . meow-back-symbol))

;; Selection
(meow-normal-define-key
 '("<escape>" . ignore)
 '("m" . meow-mark-word)
 '("M" . meow-mark-symbol)
 '("l" . meow-line)
 '("o" . meow-block)
 '("N" . meow-next-expand)
 '("E" . meow-prev-expand)
 '("H" . meow-left-expand)
 '("I" . meow-right-expand)
 '("g" . meow-cancel-selection)
 '("z" . meow-pop-selection)
 '("G" . meow-grab))

;; Editing
(meow-normal-define-key
 '("s" . meow-insert)
 '("a" . meow-append)
 '("S" . meow-open-above)
 '("A" . meow-open-below)
 '("c" . meow-change)
 '("d" . meow-kill)
 '("D" . meow-backward-delete)
 '("r" . meow-replace)
 '("p" . meow-yank)
 '("y" . meow-save)
 '("u" . meow-undo)
 '("U" . rm/meow-redo)
 '("j" . meow-join)
 '(">" . indent-rigidly-right)
 '("<" . indent-rigidly-left))

;; Navigation
(meow-normal-define-key
 '("[" . meow-beginning-of-thing)
 '("]" . meow-end-of-thing)
 '("," . meow-inner-of-thing)
 '("." . meow-bounds-of-thing)
 '("O" . meow-to-block)
 '("L" . meow-goto-line)
 '("f" . meow-find)
 '("t" . meow-till)
 '("v" . meow-search)
 '("/" . meow-visit))

(provide 'rm-edit)
;;; rm-edit.el ends here
