;;; init-vcs.el -*- lexical-binding: t; -*-

;;--------------------------------------------------------------------------------
;; Magit
;;--------------------------------------------------------------------------------
(use-package magit
  :commands (magit-status)
  :bind (("C-x g" . magit-status))
  :config
  (setq magit-process-coding-system '(utf-8 . utf-8)
        magit-git-process-coding-system '(utf-8 . utf-8))
  (add-to-list 'process-coding-system-alist '("git" . (utf-8 . utf-8))))

(defun my/magit-open-current-file-at-rev (rev)
  "Open the current buffer's file at REV (raw blob)."
  (interactive "sRev (e.g. HEAD~3 or <hash>): ")
  (unless (buffer-file-name)
    (user-error "This buffer is not visiting a file"))
  (let* ((root (or (vc-root-dir) default-directory))
         (rel  (file-relative-name (buffer-file-name) root)))
    (magit-find-file rev rel)))
(global-set-key (kbd "C-c g r") #'my/magit-open-current-file-at-rev)

;;--------------------------------------------------------------------------------
;; blamer.el : 行ごとの git blame オーバーレイ表示
;;--------------------------------------------------------------------------------
(use-package blamer
  :defer t
  :init
  (global-set-key (kbd "C-c g t") #'blamer-mode)
  :custom
  (blamer-idle-time 0.3)
  (blamer-pretty-time-p t)
  (blamer-author-formatter "✎ %s ")
  (blamer-datetime-formatter "[%s] ")
  (blamer-commit-formatter "● %s")
  (blamer-type 'visual)
  (blamer-max-commit-message-length 120))

;;--------------------------------------------------------------------------------
;; git-link
;;--------------------------------------------------------------------------------
(use-package git-link  :commands git-link)

(provide 'init-vcs)
