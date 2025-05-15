;;; key.el --- Keybindings
;;

(defvar-keymap helix/window-map
  :doc "Helix-style Window Manipulation Keymap"
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

(use-package meow
  :demand t
  :config
  (setq meow-cheatsheet-layout
	meow-cheatsheet-layout-colemak-dh)

  (meow--setup-diff-hl t)
  (meow--setup-corfu t)
  (meow--setup-magit t)
  (meow--setup-eldoc t)
  (meow--setup-which-key t)

  (keymap-global-set "C-c w" helix/window-map)
  
  (meow-motion-define-key
   '("e" . meow-prev)
   '("<escape>" . ignore))
   
  (meow-leader-define-key
   '("?" . meow-M-x)
   '("f" . project-find-file)
   '("F" . consult-fd)
   '("s" . consult-imenu-multi)
   '("b" . consult-project-buffer)
   '("B" . consult-buffer)
   '("j" . consult-bookmark)
   '("d" . consult-flymake)
   '("a" . eglot-code-actions)
   '("y" . meow-clipboard-save)
   '("p" . meow-clipboard-yank)
   '("r" . eglot-rename)
   '("/" . consult-ripgrep)
   '("k" . eldoc)
   '("c" . comment-dwim)
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument))

  (meow-normal-define-key
   '("1" . meow-expand-1)
   '("2" . meow-expand-2)
   '("3" . meow-expand-3)
   '("4" . meow-expand-4)
   '("5" . meow-expand-5)
   '("6" . meow-expand-6)
   '("7" . meow-expand-7)
   '("8" . meow-expand-8)
   '("9" . meow-expand-9)
   '("0" . meow-expand-0)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("/" . meow-visit)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("e" . meow-prev)
   '("E" . meow-prev-expand)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-right)
   '("I" . meow-right-expand)
   '("j" . meow-join)
   '("k" . meow-kill)
   '("l" . meow-line)
   '("L" . meow-goto-line)
   '("m" . meow-mark-word)
   '("M" . meow-mark-symbol)
   '("n" . meow-next)
   '("N" . meow-next-expand)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("r" . meow-replace)
   '("s" . meow-insert)
   '("S" . meow-open-above)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-search)
   '("w" . meow-next-word)
   '("W" . meow-next-symbol)
   '("x" . meow-delete)
   '("X" . meow-backward-delete)
   '("y" . meow-save)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore))
  (meow-global-mode))

;; key.el ends here
