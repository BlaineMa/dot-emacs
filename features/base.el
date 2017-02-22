;; ------ global keybindings
(use-package general
  :config
  (progn
    (use-package key-chord :defer 1 :config (setq key-chord-two-keys-delay 0.2))
    ;; C-x-
    (general-define-key :prefix "C-x"
                        "d" 'delete-whitespace-rectangle
                        "F" 'set-fill-column
                        "t" 'toggle-truncate-lines
                        "y" '(lambda() (interactive) (blaine/insert-separator nil))
                        "Y" '(lambda() (interactive) (blaine/insert-separator t))
                        "v" 'blaine/buffer-info
                        ;; ------ C-x C-
                        "C-d" 'blaine/duplicate-line
                        "C-j" 'dired-jump
                        "C-e" 'pp-eval-last-sexp
                        "C-o" 'blaine/kill-other-buffers
                        "C-f" 'counsel-find-file)
    ;; C-c-
    (general-define-key :prefix "C-c"
                        "SPC" 'just-one-space
                        "C-f" 'blaine/format-buffer
                        "f"   'flush-lines
                        "g"   'goto-line
                        "k"   'keep-lines
                        "o"   'customize-option
                        "O"   'customize-group
                        "F"   'customize-face
                        "q"   'fill-region
                        "["   'align-regexp
                        "="   'count-matches
                        ";"   'comment-or-uncomment-region)
    ;; C-
    (general-define-key "C-a" 'blaine/beginning-of-line
                        "C-M-j" '(lambda() (interactive) (delete-indentation t))
                        "C-c C-r" 'ivy-resume
                        "C-;" 'hydra-projectile/body)
    ;; M-
    (general-define-key "M-!" 'async-shell-command
                        "<M-backspace>" 'blaine/contextual-backspace
                        "M-`" 'other-frame
                        "M-y" 'counsel-yank-pop)
    ;; system related, like copy&paste
    (general-define-key "M-q" 'save-buffers-kill-terminal
                        "M-v" 'yank
                        "M-c" 'kill-ring-save
                        "M-x" '(lambda() (interactive)
                                 (if (use-region-p)
                                     (call-interactively 'kill-region)
                                   (call-interactively 'counsel-M-x)))
                        "M-w" 'delete-window
                        "M-W" 'delete-frame
                        "M-n" 'make-frame
                        "M-z" 'undo-tree-undo
                        "M-r" 'undo-tree-redo
                        "M-Z" 'undo-tree-undo
                        "M-s" (lambda () (interactive)
                                (call-interactively (key-binding "\C-x\C-s")))
                        "C-M-v" 'scroll-down-command)
    (with-eval-after-load 'term
      (define-key term-raw-map (kbd "M-v") 'term-paste))
    ;; (unbind-key "C-y")
    ;; (define-key 'isearch-mode-map "M-v" 'isearch-yank-kill)
    ;; C-c e -
    (general-define-key :prefix "C-c e"
                        "E" 'elint-current-buffer
                        "b" '(lambda () (interactive) (call-interactively 'eval-buffer))
                        "C" 'cancel-debug-on-entry
                        "d" 'debug-on-entry
                        "e" 'toggle-debug-on-error
                        "f" 'emacs-lisp-byte-compile-and-load
                        "j" 'emacs-lisp-mode
                        "l" 'find-library
                        "r" '(lambda () (interactive) (call-interactively 'eval-region))
                        "z" 'byte-recompile-directory)
    ;; C-h e -
    (define-prefix-command 'blaine--lisp-find-map)
    (bind-key "C-h e" 'blaine--lisp-find-map)
    (general-define-key :keymaps 'blaine--lisp-find-map
                        "c" 'finder-commentary
                        "e" 'view-echo-area-messages
                        "f" 'find-function
                        "F" 'find-face-definition
                        "i" 'info-apropos
                        "k" 'find-function-on-key
                        "l" 'find-library
                        "s" 'blaine/scratch
                        "v" 'find-variable
                        "V" 'apropos-value
                        "t" 'blaine/what-face)
    ))

;; ------ packages
(let ((use-package-always-ensure t))

  (use-package diminish)
  (use-package bind-key)
  (use-package use-package-chords :config (key-chord-mode 1))
  (use-package server :config (unless (server-running-p) (server-start)))
  (use-package restart-emacs)
  (use-package session)
  ;; (use-package cus-edit)
  (use-package hydra)
  (use-package which-key
    :diminish (which-key-mode . " ⓦ")
    :config
    (progn
      (which-key-mode)
      (which-key-setup-side-window-bottom)
      ;; (which-key-setup-minibuffer)
      ))

  (use-package ivy :demand t
    :diminish (ivy-mode . "")
    :config   (ivy-mode 1))

  (use-package counsel
    :commands (counsel-M-x
               counsel-find-file
               counsel-git
               counsel-git-grep
               counsel-ag
               counsel-locate
               counsel-describe-function
               counsel-describe-variable
               counsel-find-library
               counsel-info-lookup-symbol
               counsel-unicode-char))

  (use-package projectile
    :diminish (projectile-mode . " ⓟ")
    :commands (projectile-mode
               projectile-global-mode
               hydra-projectile/body
               hydra-projectile-if-projectile-p
               projectile-project-root
               projectile-project-p
               counsel-projectile-switch-to-buffer)
    :config
    (progn 
      (projectile-global-mode 1)
      ;; https://github.com/ericdanan/counsel-projectile
      (use-package counsel-projectile :config (counsel-projectile-on))
      (defun hydra-projectile-if-projectile-p ()
        (interactive)
        (if (projectile-project-p)
            (hydra-projectile/body)
          (counsel-projectile)))

      (defhydra hydra-projectile (:color teal :hint nil)
        "
     PROJECTILE: %(projectile-project-root)
    ^FIND FILE^        ^SEARCH/TAGS^        ^BUFFERS^       ^CACHE^                    ^PROJECT^
    _f_: file          _s_: ag              _i_: Ibuffer    _c_: cache clear           _p_: switch proj
    _F_: file dwim     _g_: update gtags    _b_: switch to  _x_: remove known project
  _C-f_: file pwd      _o_: multi-occur   _s-k_: Kill all   _X_: cleanup non-existing
    _r_: recent file   ^ ^                  ^ ^             _z_: cache current
    _d_: dir
"
        ("s"   counsel-projectile-ag)
        ("b"   counsel-projectile-switch-to-buffer)
        ("c"   projectile-invalidate-cache)
        ("d"   counsel-projectile-find-dir)
        ("f"   counsel-projectile-find-file)
        ("F"   projectile-find-file-dwim)
        ("C-f" projectile-find-file-in-directory)
        ;; ("g"   ggtags-update-tags)
        ;; ("s-g" ggtags-update-tags)
        ("i"   projectile-ibuffer)
        ("K"   projectile-kill-buffers)
        ("s-k" projectile-kill-buffers)
        ("m"   projectile-multi-occur)
        ("o"   projectile-multi-occur)
        ("p"   counsel-projectile-switch-project)
        ("r"   projectile-recentf)
        ("x"   projectile-remove-known-project)
        ("X"   projectile-cleanup-known-projects)
        ("z"   projectile-cache-current-file)
        ("q"   nil "cancel" :color blue))))

  (use-package undo-tree
    :commands (undo-tree-visualize
               undo-tree-undo
               undo-tree-redo))

  (use-package exec-path-from-shell
    :defer 2
    :commands (exec-path-from-shell-initialize
               exec-path-from-shell-copy-env)
    :config
    (exec-path-from-shell-initialize))

  ) ;; let ends here