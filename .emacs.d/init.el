(setq custom-file (concat user-emacs-directory "custom.el"))

(load-file (concat user-emacs-directory "custom.el"))

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Hide unnecessary GUI elements
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Inconsolata
(set-face-attribute 'default t :font "Inconsolata Medium")

(require 'bind-key)

(condition-case err
    (progn
      (require 'use-package))
    (error
     (debug "Unable to load use-package. Continue?")))

(use-package general
  :ensure t)

;; Bind C-c i to editing the init file
(defun visit-init-file ()
  (interactive)
  (find-file-other-window "~/.emacs.d/init.el"))

(defun visit-journal ()
  (interactive)
  (find-file-other-window "~/.diary/journal.org"))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :custom
  ((evil-search-wrap t)
   (evil-regexp-search t))
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-numbers
  :after evil
  :config
  (define-key evil-normal-state-map (kbd "C-a") 'evil-numbers/inc-at-pt)
  (define-key evil-normal-state-map (kbd "C-x") 'evil-numbers/dec-at-pt))

(use-package evil-org
  :after org
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package sourcerer-theme
  :config (load-theme 'sourcerer t))

(use-package org
  :hook (org-mode . auto-fill-mode)
  :bind
  (("C-c a" . org-agenda)
   ("C-c c" . org-capture))

  :custom
  ((org-default-notes-file "journal.org")
   (org-directory "~/diary")
   (org-agenda-todo-ignore-scheduled t)
   (org-agenda-todo-ignore-with-date t)
   (org-todo-keywords '((sequence "TOBUY(b)" "|" "bought(B)")
			(sequence "TODO(t)" "WAIT(w)" "|" "DONE(d)")
			(sequence "|" "CANCELED(c)")))
				  
   (org-use-fast-todo-selection t)
   (org-capture-templates
    '(("t" "TODO task" entry (file "") (file "templates/todo.org"))
      ("j" "journal" entry (file "") (file "templates/journal.org"))
      ("m" "Meeting" entry (file "calendar.org") (file "templates/meeting.org"))))
   (org-habit-graph-column 65)
   (org-file-apps '((auto-mode . emacs)
		    (directory . emacs)
		    ("\\.mm\\'" . default)
		    ("\\.x?html?\\'" . default)
		    ("\\.pdf\\'" . "/usr/bin/zathura --fork %s"))))
			       
  :config
  (add-to-list 'org-modules 'org-habit))

(use-package eshell
  :bind ("C-c e" . eshell))

(use-package slime
  :config
  (setq inferior-lisp-program "sbcl"))

(use-package projectile)

(use-package lsp-mode)
(use-package lsp-ui)
(use-package company)

(use-package which-key
  :config
  (which-key-setup-minibuffer)
  (which-key-mode))

;; Keybindings

;; Because I map C-x to decrease numbers as in Vim, we need to refiine all
;; C-x ??? commands

(general-create-definer leader-def
  :prefix "SPC")
(general-create-definer ins-leader-def
  :prefix "M-SPC")

(general-auto-unbind-keys)

(leader-def
  :keymaps 'normal
  "a" 'org-agenda
  "c" 'org-capture
  "ei" 'visit-init-file
  "ej" 'visit-journal)

(leader-def
  :states 'motion
  :keymaps 'org-mode-map
  "," 'org-priority
  "t" 'org-todo
  "s" 'org-schedule)

(general-def
  :states 'insert
  :keymaps 'org-mode-map
  "RET" 'evil-org-return)

(ins-leader-def
  :states 'insert
  :keymaps 'org-mode-map
  :major-modes t
  "." 'org-time-stamp
  "!" 'org-time-stamp-inactive
  "RET" 'org-insert-heading)
