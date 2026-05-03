;;; init-lang-php.el -*- lexical-binding: t; -*-

;;--------------------------------------------------------------------------------
;; PHP
;;--------------------------------------------------------------------------------
(use-package php-mode
  :mode "\\.php\\'"
  :hook (php-mode . my/php-mode-setup))

(defun my/php-mode-setup ()
  ;; インデント周りはお好みで
  (setq-local indent-tabs-mode nil
              tab-width 4
              c-basic-offset 4))

(provide 'init-lang-php)
