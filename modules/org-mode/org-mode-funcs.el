;;; org-mode-funcs.el --- Summary
;;; Commentary:
;;; Code:

(defun org-setup-headers ()
  "Setup the title and headers for `org-mode'."
  (let* ((variable-tuple (cond ((x-list-fonts "Source Sans Pro") '(:font "Source Sans Pro"))
			       ((x-list-fonts "Lucida Grande")   '(:font "Lucida Grande"))
			       ((x-list-fonts "Verdana")         '(:font "Verdana"))
			       ((x-family-fonts "Sans Serif")    '(:family "Sans Serif"))
			       (nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro."))))
	 (headline           `(:inherit default :weight bold :background nil)))

    (custom-theme-set-faces 'user
			    `(org-level-8 ((t (,@headline ,@variable-tuple))))
			    `(org-level-7 ((t (,@headline ,@variable-tuple))))
			    `(org-level-6 ((t (,@headline ,@variable-tuple))))
			    `(org-level-5 ((t (,@headline ,@variable-tuple))))
			    `(org-level-4 ((t (,@headline ,@variable-tuple :height 1))))
			    `(org-level-3 ((t (,@headline ,@variable-tuple :height 1.1))))
			    `(org-level-2 ((t (,@headline ,@variable-tuple :height 1.25))))
			    `(org-level-1 ((t (,@headline ,@variable-tuple :height 1.5))))
			    `(org-document-title ((t (,@headline ,@variable-tuple :height 1.5 :underline nil)))))))

(provide 'org-mode-funcs)
;;; org-mode-funcs.el ends here
