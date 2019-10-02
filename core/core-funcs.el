;; core-funcs.el
(provide 'core-funcs)

(defun setup-use-package ()
  (require 'package)
  (setq package-enable-at-startup nil)
  (setq package-archives '(("org"       . "http://orgmode.org/elpa/")
				   ("gnu"       . "http://elpa.gnu.org/packages/")
				   ("melpa-stable"     . "http://stable.melpa.org/packages/")
				   ("melpa"     . "http://melpa.milkbox.net/packages/")
				   ("marmalade" . "http://marmalade-repo.org/packages/")))

  (package-initialize)
  (unless (package-installed-p 'use-package) ; unless it is already installed
    (package-refresh-contents) ; updage packages archive
    (package-install 'use-package)) ; and install the most recent version of use-package
  (require 'use-package))


(defun clean-dir-files (path)
  "Return contents of a directory without . and .. "
  (remove ".." (remove "." (directory-files path))))


(defun recompile-config-modules ()
  "Byte compile everything in the `~/.emacs.d/modules/' directory"
  (interactive)
  (let ((prefix "~/.emacs.d/modules/"))
    (mapcar (lambda (x)
	      (byte-recompile-directory (concat prefix x) 0))
	    (clean-dir-files prefix))))


(defun new-empty-buffer ()
  "Create a new buffer called untitled(<n>)"
  (interactive)
  (let ((newbuf (generate-new-buffer-name "untitled")))
    (switch-to-buffer newbuf)))


(defun switch-to-scratch-buffer ()
  "Switch to the `*scratch*' buffer. Create it if needed."
  (interactive)
  (let ((exists (get-buffer "*scratch*")))
    (switch-to-buffer (get-buffer-create "*scratch*"))
    (when (and (not exists)
	       (not (eq major-mode scratch-mode))
	       (fboundp scratch-mode))
      (funcall scratch-mode))))

(defun add-path-string-to-exec-path (str)
  "add all my paths to the exec path"
  (mapcar (lambda (s) (setenv "PATH" (concat s))) (split-string str ":")))


;; refactor to exclude modules eventually
;;;###autoload
(defun add-all-modules ()
  (mapcar (lambda (x)
	    (progn
	      (add-to-list 'load-path (concat modules-dir x))
	      (require (intern x))))
	  ;; don't include core twice
	  (remove "langs" (remove "core" (clean-dir-files modules-dir)))))

;;;###autoload
(defun add-langs ()
  (mapcar (lambda (x)
	    (progn
	      (add-to-list 'load-path (concat langs-dir x))
	      (require (intern x))))
	  (clean-dir-files langs-dir)))

(defun raise-gc-on-init ()
  "Set garbage collection to be higher on initialisation"
  (setq gc-cons-threshold 50000000)
  (add-hook 'emacs-startup-hook (lambda ()
	      (setq gc-cons-threshold 800000))))


(defvar my-skippable-buffers '("*Messages*" "*Completions*" "*Help*" "*Buffer List*" "Shell-popup")
  "Buffer names ignored by `next-buffer' and `previous-buffer'.")

(defun my-buffer-predicate (buffer)
  (if (member (buffer-name buffer) my-skippable-buffers)
      nil
    t))
(set-frame-parameter nil 'buffer-predicate 'my-buffer-predicate)

;; stolen right out of spacemacs
(defun neotree-expand-or-open ()
  "Expand or open a neotree node."
  (interactive)
  (let ((node (neo-buffer--get-filename-current-line)))
    (when node
      (if (file-directory-p node)
	  (progn
	    (neo-buffer--set-expand node t)
	    (neo-buffer--refresh t)
	    (when neo-auto-indent-point
	      (next-line)
	      (neo-point-auto-indent)))
	(call-interactively 'neotree-enter)))))

;; neotree funcs
(defun neotree-collapse ()
  "Collapse a neotree node."
  (interactive)
  (let ((node (neo-buffer--get-filename-current-line)))
    (when node
      (when (file-directory-p node)
	(neo-buffer--set-expand node nil)
	(neo-buffer--refresh t))
      (when neo-auto-indent-point
	(neo-point-auto-indent)))))

(defun neotree-collapse-or-up ()
  "Collapse an expanded directory node or go to the parent mode."
  (interactive)
  (let ((node (neo-buffer--get-filename-current-line)))
    (when node
      (if (file-directory-p node)
	  (if (neo-buffer--expanded-node-p node)
	      (neotree-collapse))
	(neotree-select-up-node))
      (neotree-select-up-node))))

(defun create-popup (fname buf-name popup-func height select)
  "Create a popup window which calls a function upon opening if select is t then the window will become the active window upon opening"
  (if (not (get fname 'state))
      (let ((win (split-window (frame-root-window) height)))
	(when 'select
	  (select-window win))
	(get-buffer-create buf-name)
	(funcall popup-func)
	(put fname 'state win))
    (progn
      (let ((win (get fname 'state)))
	(delete-window win)
	(put fname 'state nil)))))

(defun shell-toggle ()
  (interactive)
  (if (not (get :shell-toggle 'state))
      (let* ((buffer (get-buffer-create "Shell-popup"))
	     (win (display-buffer-in-side-window buffer `((window-height . 12)))))
	(shell buffer)
	(set-frame-font "MesloLGS NF")
	(put :shell-toggle 'state win))
    (progn
      (let ((win (get :shell-toggle 'state)))
	(delete-window win)
	(put :shell-toggle 'state nil)))))

(defun eshell-toggle ()
  (interactive)
  (create-popup
   'eshell-toggle "eshell" 'eshell -10 t))

(defun elisp-repl-toggle ()
  (interactive)
  (create-popup
   'ielm-toggle "repl" 'ielm -10 t))


(defun initialise-core ()
  "Start the configuration"
  (progn
    (raise-gc-on-init)
    (setup-use-package)
    (general-evil-setup)
    (add-all-modules)))