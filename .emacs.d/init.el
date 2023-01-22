(setq custom-file (concat user-emacs-directory "custom.el"))

(load-file (concat user-emacs-directory "custom.el"))

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Hide unnecessary GUI elements
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;j; Inconsolata
(set-face-attribute 'default t :font "Inconsolata Medium")

(require 'bind-key)

;; Bind C-c i to editing the init file
(bind-key
 (kbd "C-c i")
 (lambda ()
   (interactive)
   (find-file "~/.emacs.d/init.el")))

(require 'use-package)

(use-package evil
  :config
  (evil-mode 1))

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

(use-package evil-org
  :after org
  :hook (org-mode . (lambda () (evil-org-mode)))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package god-mode)

(use-package evil-god-state
  :after evil god-mode
  :config
  (evil-define-key 'normal global-map "," 'evil-execute-in-god-state)
  (evil-define-key 'god global-map [escape] 'evil-god-state-bail))
