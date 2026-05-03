;;; init-lang-go.el -*- lexical-binding: t; -*-

;;--------------------------------------------------------------------------------
;; Go
;;--------------------------------------------------------------------------------
(use-package go-mode
  :mode "\\.go\\'"
  :init
  ;; 保存時に import の追加/削除/整列まで行いたいなら goimports を使う
  ;; go install golang.org/x/tools/cmd/goimports@latest
  (setq gofmt-command "goimports")
  :hook
  (go-mode . (lambda ()
               ;; Go バッファ限定で保存時に整形する
               (add-hook 'before-save-hook #'gofmt-before-save nil t)
               ;; Go のインデント定義（Copilot 対策）
               (setq-local indent-tabs-mode t)
               (setq-local tab-width 8)
               (setq-local go-tab-width 8))))

(provide 'init-lang-go)
