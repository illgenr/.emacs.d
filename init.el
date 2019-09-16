;; Set your lisp system and, optionally, some contribs

(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

(load (expand-file-name "~/.roswell/helper.el"))
(setq inferior-lisp-program "ros -Q run")
(setq slime-contribs '(slime-fancy))


;; vanilla emacs options
(global-set-key [67108923] 'other-window)
(global-set-key [67108903] 'other-frame)

(setq visible-bell 1)

(global-visual-line-mode t)

(menu-bar-mode 0)

;; helm config
(require 'helm)
(require 'helm-config)

;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(global-unset-key (kbd "C-x C-b"))
(global-set-key (kbd "C-x C-b") 'helm-mini)

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
      helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ff-file-name-history-use-recentf t
      helm-echo-input-in-header-line t)

(setq helm-autoresize-max-height 0)
(setq helm-autoresize-min-height 20)
(helm-autoresize-mode 1)

(helm-mode 1)

(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x C-n") 'dired-sidebar-toggle-sidebar)

;; function keys
(define-key global-map [f5] 'compile)

;; bookmarks stuff--
(define-key global-map [f9] 'bookmark-jump)
(define-key global-map [f11] 'bookmark-set)
(setq bookmark-default-file "~/.emacs.d/bookmarks")  ;;define file to use.
(setq bookmark-save-flag 1)  ;save bookmarks to .emacs.bmk after each entry

;; magit
(use-package magit
  :commands magit-status
  :init (bind-key "C-x g" 'magit-status))

(use-package magithub
  :after magit
  :ensure t
  :config (magithub-feature-autoinject t))

;;
;; ace jump mode major function
;; 
(use-package ace-jump-mode
  :commands ace-jump-mode
  :init
  (bind-key "C-." 'ace-jump-mode))

;; 
;; enable a more powerful jump back function from ace jump mode
;;
(use-package ace-jump-mode
  :commands ace-jump-mode-pop-mark
  :init (bind-key "C-c SPC" 'ace-jump-mode-pop-mark))

;; start auto-complete with emacs
(require 'auto-complete)
;;do default config for auto complete
(require 'auto-complete-config)
(ac-config-default)

;; Multiple cursors
(use-package multiple-cursors
  :commands mc/edit-lines
  :init (bind-key  (kbd "C-S-c C-S-c") 'mc/edit-lines))

(use-package cloc)

;; Org mode
(setq org-directory "~/org")
;; Org Agenda
(use-package org-agenda
  :commands org-agenda
  :init (bind-key  (kbd "C-c a") 'org-agenda))
;; Org capture
(setq org-default-notes-file (concat org-directory "/inbox.org"))
(use-package org-capture
  :commands org-capture
  :init (bind-key  (kbd "C-c c") 'org-capture))

;; Go Configuration
(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (replace-regexp-in-string
                          "[ \t\n]*$"
                          ""
                          (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq eshell-path-env path-from-shell) ; for eshell users
    (setq exec-path (split-string path-from-shell path-separator))))

(when window-system (set-exec-path-from-shell-PATH))

;; (setenv "GOPATH" "$HOME/go")

(defun auto-complete-for-go ()
(auto-complete-mode 1))
(add-hook 'go-mode-hook 'auto-complete-for-go)

(with-eval-after-load 'go-mode
  (require 'go-autocomplete))

(defun my-go-mode-hook ()
  ; Use goimports instead of go-fmt
  (setq gofmt-command "goimports")
  ; Call Gofmt before saving
  (add-hook 'before-save-hook 'gofmt-before-save)
  ; Customize compile command to run go build
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
           "go build -v && go test -v && go vet"))
  ; Godef jump key binding
  (local-set-key (kbd "M-.") 'godef-jump)
  (local-set-key (kbd "M-*") 'pop-tag-mark)
)
(add-hook 'go-mode-hook 'my-go-mode-hook)

;; bin path
(add-to-list 'exec-path "$HOME/go/bin")

;; JS specific
;; Flow
(load-file "~/.emacs.d/flow-for-emacs/flow.el")
(add-hook 'js2-mode-hook 'flow-minor-enable-automatically)

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(helm-autoresize-min-height 50)
 '(helm-buffer-max-length 50)
 '(menu-bar-mode nil)
 '(org-agenda-files nil)
 '(package-selected-packages
   (quote
    (lsp-javascript-flow flycheck-flow flow-minor-mode yasnippet-snippets yasnippet-classic-snippets company-go flycheck go-projectile go-autocomplete exec-path-from-shell go-mode cider org-super-agenda rust-mode racket-mode inf-clojure clojure-mode ac-ispell rainbow-blocks alarm-clock cloc magit magithub ibuffer-sidebar dired-sidebar vscode-icon auto-complete-auctex auto-complete helm dash dash-functional frame-local ov projectile s helm-descbinds slime))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
