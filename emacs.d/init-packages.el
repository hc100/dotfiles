;;; init-packages.el -*- lexical-binding: t; -*-

;;--------------------------------------------------------------------------------
;; straight.el ブートストラップ + use-package を straight 経由に
;;--------------------------------------------------------------------------------
(defvar bootstrap-version)
(let* ((repo-dir (expand-file-name "straight/repos/straight.el" user-emacs-directory))
       (bootstrap-file (expand-file-name "bootstrap.el" repo-dir)))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(require 'use-package)

;;--------------------------------------------------------------------------------
;; macOS の環境変数: PATHは自前で管理し、それ以外だけ取り込む
;;--------------------------------------------------------------------------------
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :config
  ;; PATH を上書きさせない（ここが肝）
  (setq exec-path-from-shell-variables
        '("LANG" "LC_ALL" "SSH_AUTH_SOCK" "GPG_AGENT_INFO" "NVM_DIR"))
  (exec-path-from-shell-initialize))

;; delight 本体（必要に応じて各 use-package に :delight を付与）
(use-package delight)

(provide 'init-packages)
