;;; rm-edit.el --- Keybindings for Editing -*- lexical-binding: t -*-
(meow-global-mode +1)        ; Modal Editing
(electric-pair-mode +1)      ; Matching pairs
(delete-selection-mode +1)   ; Delete selected text on typing
(global-auto-revert-mode +1) ; Revert file when out-of-sync

;; Sane Defaults
(setopt tab-width 3
        standard-indent 3
        tab-always-indent 'complete                                             ; Complete if indented
        indent-tabs-mode nil                                                    ; Don't use tabs for indent
        text-mode-ispell-word-completion nil                                    ; Disable ispell completion in text mode
        mac-command-modifier 'meta
        read-extended-command-predicate #'command-completion-default-include-p) ; Filter M-x commands

(setopt mac-command-modifier 'meta
        mac-option-modifier 'none)

;; Ghostty Quick Terminal
(unbind-key "<f3>")

;; +embark
(setopt prefix-help-command #'embark-prefix-help-command)

(keymap-global-set "C-." 'embark-act)
(keymap-global-set "C-;" 'embark-dwim)
(keymap-global-set "C-h B" 'embark-bindings)

(add-to-list 'display-buffer-alist
             '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
               nil
               (window-parameters (mode-line-format . none))))

;; +git-link
(keymap-global-set "C-c g l" 'git-link)

;; +windmove
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

;; +meow
(require 'meow) ; Meow is auto-loaded when meow-global-mode is called, but just for my sanity.

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

(defvar-keymap rm/goto-map
  :doc "Keymap for navigation commands inspired by Helix"
  "e" #'end-of-buffer
  "f" #'find-file-at-point
  "h" #'beginning-of-line
  "l" #'end-of-line
  "s" #'back-to-indentation
  "d" #'xref-find-definitions
  "D" #'eglot-find-declaration
  "y" #'eglot-find-typeDefinition
  "r" #'xref-find-references
  "i" #'eglot-find-implementation
  "t" #'beginning-of-buffer
  "c" #'recenter-top-bottom
  "n" #'next-buffer
  "p" #'previous-buffer
  "k" #'previous-line
  "j" #'next-line)

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
 (cons "g" rm/goto-map)
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
