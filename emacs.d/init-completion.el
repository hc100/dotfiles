;;; init-completion.el -*- lexical-binding: t; -*-

;;--------------------------------------------------------------------------------
;; corfu + nerd-icons
;;--------------------------------------------------------------------------------
(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  (corfu-popupinfo-delay '(0.5 . 0.2))
  :config
  (setq corfu-min-width 250
        corfu-min-height 750
        corfu-count 20
        corfu-auto t
        corfu-cycle t
        corfu-separator ?\s
        corfu-preview-current "insert"
        corfu-scroll-margin 25
        tab-always-indent 'complete)
  (corfu-popupinfo-mode 1)
  ;; 履歴でソート
  (with-eval-after-load 'savehist
    (corfu-history-mode 1)
    (add-to-list 'savehist-additional-variables 'corfu-history)))

(use-package cape
  :init
  ;; Corfu / Eglot が使う CAPF に汎用補完を足す
  (add-to-list 'completion-at-point-functions #'cape-file)
  :config
  (add-hook 'prog-mode-hook #'my/setup-programming-capf))

(defun my/setup-programming-capf ()
  "Add fallback CAPFs for programming buffers."
  (add-to-list 'completion-at-point-functions #'cape-dabbrev t))

;; アイコン本体
(use-package nerd-icons)

;; ミニバッファ / M-x / completion 等にアイコン
(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-marginalia-setup)
  (nerd-icons-completion-mode 1))

;; corfu にアイコンを出す
(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;;--------------------------------------------------------------------------------
;; EditorConfig / yasnippet
;;--------------------------------------------------------------------------------
(use-package editorconfig
  :delight editorconfig-mode
  :config (editorconfig-mode 1))

(use-package yasnippet
  :delight yas-minor-mode
  :config (yas-global-mode 1))

(use-package yasnippet-snippets)

(with-eval-after-load 'editorconfig
  ;; go-mode 用（go-tab-width を使わせる）
  (add-to-list 'editorconfig-indentation-alist '(go-mode go-tab-width)))

;;--------------------------------------------------------------------------------
;; copilot
;;--------------------------------------------------------------------------------
(defun my/copilot-disable-non-file-buffers ()
  (not buffer-file-name))  ;; ファイル訪問じゃなければ無効

(defun my/copilot-disable-star-buffers ()
  "Disable Copilot for *scratch*, *Messages*, and other *foo* buffers."
  (string-match-p "^\\*.*\\*$" (buffer-name)))

(defun my/copilot-disable-large-buffers ()
  "Disable Copilot before it warns about buffers over `copilot-max-char'."
  (and (boundp 'copilot-max-char)
       (> (buffer-size) copilot-max-char)))

(defun my/copilot-enable-if-supported ()
  "Enable Copilot only for buffers where it can provide completions quietly."
  (unless (or (my/copilot-disable-non-file-buffers)
              (my/copilot-disable-star-buffers)
              (my/copilot-disable-large-buffers))
    (copilot-mode 1)))

(use-package copilot
  :delight copilot-mode
  :hook (prog-mode . my/copilot-enable-if-supported)
  :bind (:map copilot-completion-map
              ("<tab>"     . copilot-accept-completion)
              ("TAB"       . copilot-accept-completion)
              ("C-TAB"     . copilot-accept-completion-by-word)
              ("C-S-TAB"   . copilot-accept-completion-by-line)))

(when-let ((copilot-language-server (executable-find "copilot-language-server")))
  (setq copilot-server-executable copilot-language-server))

(with-eval-after-load 'copilot
  (add-to-list 'copilot-disable-predicates #'my/copilot-disable-non-file-buffers)
  (add-to-list 'copilot-disable-predicates #'my/copilot-disable-large-buffers)
  (add-to-list 'copilot-disable-predicates #'my/copilot-disable-star-buffers))

;;--------------------------------------------------------------------------------
;; Vertico + Consult + Orderless + Marginalia
;;--------------------------------------------------------------------------------
(use-package vertico
  :init
  (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles . (orderless))))))

(use-package consult
  :bind
  (("C-x C-f" . find-file)      ;; ← 元の動きに戻す
   ("C-x b"   . consult-buffer)
   ("C-c f"   . consult-fd)))

(use-package marginalia
  :init
  (marginalia-mode))

(provide 'init-completion)
