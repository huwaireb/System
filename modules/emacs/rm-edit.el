;;; rm-edit.el --- Keybindings for Editing -*- lexical-binding: t -*-
(require 'windmove)
(require 'meow)

;; --- Window Management Keybindings ---

(defvar-keymap rm/window-map
  :doc "Window manipulation keymap inspired by Helix"
  "w" #'other-window
  "s" #'split-window-below
  "v" #'split-window-right
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

;; --- Meow Modal Editing Keybindings ---

(add-hook 'after-init-hook #'meow-global-mode)

(defun meow-redo ()
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
 '("p" . meow-clipboard-yank))
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
 '("x" . meow-delete)
 '("X" . meow-backward-delete)
 '("k" . meow-kill)
 '("r" . meow-replace)
 '("p" . meow-yank)
 '("y" . meow-save)
 '("u" . meow-undo)
 '("U" . meow-redo)
 '("j" . meow-join))

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
