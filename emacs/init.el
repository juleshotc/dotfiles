;;; init.el -*- lexical-binding: t; -*-

;; UI / behavior
(setq inhibit-startup-message t
      ring-bell-function 'ignore
      disabled-command-function nil)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(set-fringe-mode 10)
(blink-cursor-mode 0)
(setq-default truncate-lines t)

;; Backups / autosaves
(let ((autosaves (expand-file-name "autosaves/" user-emacs-directory))
      (backups  (expand-file-name "backups/"  user-emacs-directory)))
  (make-directory autosaves t)
  (make-directory backups  t)
  (setq backup-directory-alist `(("." . ,backups))
        auto-save-file-name-transforms `((".*" ,autosaves t))
        auto-save-list-file-prefix (expand-file-name ".saves-" autosaves)
        create-lockfiles nil))

;; Dired: suggest other dired buffer as target
(setq dired-dwim-target t)

;; Prompt y/n
(defalias 'yes-or-no-p 'y-or-n-p)

;; straight bootstrap
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq straight-use-package-by-default t)

(straight-use-package 'use-package)
(require 'use-package)

;; Completion UI
(use-package vertico
  :init (vertico-mode 1)
  :custom (vertico-cycle t))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode 1))

;; Tree-sitter
(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; Only pin old grammar tags on Emacs 30.1 (Debian-ish scenario)
(when (version<= emacs-version "30.1")
  (setq treesit-language-source-alist
        '((c    "https://github.com/tree-sitter/tree-sitter-c"    "v0.21.4")
          (cpp  "https://github.com/tree-sitter/tree-sitter-cpp"  "v0.22.3")
          (bash "https://github.com/tree-sitter/tree-sitter-bash" "v0.21.0"))))

(add-hook 'c-ts-mode-hook
          (lambda ()
            (when (treesit-language-available-p 'c)
              (setq indent-tabs-mode nil
                    c-ts-mode-indent-offset 4))))

(use-package cmake-mode
  :mode (("CMakeLists\\.txt\\'" . cmake-mode)
         ("\\.cmake\\'" . cmake-mode)))

;; Editing / git / visuals
(use-package multiple-cursors
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)
	 ("C-S-c C-S-c" . mc/edit-lines)
	 ("C-S-SPC" . mc/toggle-cursor-at-point)
	 ("<C-S-return>" . multiple-cursors-mode)))


(use-package which-key
  :init (which-key-mode 1)
  :custom (which-key-idle-delay 0.5))

(use-package magit)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(load-theme 'modus-vivendi t)

;; Keep Custom out of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; Tags / navigation
(setq xref-search-program 'ripgrep)

(use-package citre
  :defer t
  :init
  (require 'citre-config)
  ;; zypper doesn't pack universal ctags with readtags
  ;; So, point to the manually compiled binaries
  (setq citre-ctags-program "/usr/local/bin/ctags")
  (setq citre-readtags-program "/usr/local/bin/readtags")

  (global-set-key (kbd "C-x c p") #'citre-peek)
  (global-set-key (kbd "C-x c j") #'citre-jump)
  :config
  (add-hook 'citre-mode-hook
            (lambda ()
              (add-hook 'xref-backend-functions #'citre-xref-backend nil t)))
  (add-hook 'prog-mode-hook #'citre-mode))

;; Your scroll helper
(defun jules/scroll-mode (direction)
  "Scroll buffer without moving point; p=up, n=down, others exit."
  (pcase direction
    ('up   (ignore-errors (scroll-down-line)))
    ('down (ignore-errors (scroll-up-line))))
  (catch 'done
    (while t
      (message "scroll: n/down p/up (other key exits)")
      (pcase (read-event)
        (?p (ignore-errors (scroll-down-line)))
        (?n (ignore-errors (scroll-up-line)))
        (ev (setq unread-command-events (list ev))
            (throw 'done t))))))

(global-set-key (kbd "C-c p") (lambda () (interactive) (jules/scroll-mode 'up)))
(global-set-key (kbd "C-c n") (lambda () (interactive) (jules/scroll-mode 'down)))

;; nyan-mode from git (no vendoring, no nested .git)
(use-package nyan-mode
  :straight (nyan-mode :type git :host github :repo "TeMPOraL/nyan-mode")
  :config
  (nyan-mode 1)
  (nyan-start-animation))

(find-file (expand-file-name "~/startup.org"))
