(in-package :stumpwm)

;; Assume swank is present in the stumpwm image
(ql:quickload :swank)
(ql:quickload :clx-truetype)

(swank:create-server
 :dont-close t
 :port (+ swank::default-server-port 10))

(when (member "ttf-fonts" (list-modules) :test #'string=)
  (load-module "ttf-fonts")
  ;; For some reason, ttf-fonts is very unfriendly so we have to
  ;; do a bit of setup

  ;; Load each TTF font file into the font cache.
  ;; Note this does NOT work with ttc files
  ;; This is necessary because the 'xft:font constructor reads this cache instead of searching
  ;; for a font in the file system.
  ;;
  ;; FIXME: Support ttc font files
  (clx-truetype:cache-fonts)
  (handler-case
      (set-font (make-instance 'xft:font
			       :family "Inconsolata Medium"
			       :subfamily "Regular"))
    (simple-error (condition) (dformat 0 "Unable to set font~%~A~%" condition))))

(undefine-key *root-map* (kbd "a"))
(undefine-key *root-map* (kbd "C-a"))
(define-key *root-map* (kbd "t") "time")
(define-key *root-map* (kbd "RET") "exec alacritty")
(define-key *root-map* (kbd "d") "exec dmenu_run")
(define-key *root-map* (kbd "o") "fother")
(define-key *root-map* (kbd "n") "fnext")
(define-key *root-map* (kbd "p") "fprev")

;; Vim-like keybindings for managing frames
(define-key *root-map* (kbd "h") "move-focus left")
(define-key *root-map* (kbd "j") "move-focus down")
(define-key *root-map* (kbd "k") "move-focus up")
(define-key *root-map* (kbd "l") "move-focus right")
(define-key *root-map* (kbd "H") "move-window left")
(define-key *root-map* (kbd "J") "move-window down")
(define-key *root-map* (kbd "K") "move-window up")
(define-key *root-map* (kbd "L") "move-window right")
(define-key *root-map* (kbd "q") "kill-window")
(define-key *root-map* (kbd "w") "fother")


;; Use Emacs daemon instead default Stump Emacs behavior
(undefine-key *root-map* (kbd "e"))
(undefine-key *root-map* (kbd "C-e"))
(define-key *root-map* (kbd "e") "my-emacs")
(define-key *root-map* (kbd "Q") "quit-confirm")

;; List groups instead of Stump's default
(undefine-key *root-map* (kbd "g"))
(define-key *root-map* (kbd "g") "grouplist")

(define-key *float-group-root-map* (kbd "f") "fullscreen")

(defun window-emacs-p (window) (equal (window-class window) "Emacs"))

(defcommand my-emacs () ()
  (let ((*run-or-raise-all-groups* nil))
    (run-or-raise "emacsclient -c" (list :class "Emacs"))))


;; Pretty colors based on https://github.com/xero/sourceror
(setf *colors*
      (list
       ;; black
       "#222222"
       ;; red
       "#aa4450"
       ;; green
       "#858253"
       ;; yellow
       "#d0770f"
       ;; blue
       "#86aed5"
       ;; magenta
       "#8686ae"
       ;; cyan
       "#5b8583"
       ;; white
       "#c2c2b0"))
(update-color-map (current-screen))

(set-fg-color "#c2c2b0")
(set-bg-color "#222222")
(set-border-color "#8686ae")
(set-win-bg-color "#222222")
(set-focus-color "#5b8583")
(setf *window-border-style* :thin)

;; Make some default groups (TODO: make more)
(add-group (current-screen) "Games" :background t)

(setf *mouse-focus-policy* :click)

(defun group-by-name (name &optional (screen (current-screen)))
  (let ((gs (screen-groups screen)))
    (find-if (lambda (n) (equal n name)) gs :key #'group-name)))
