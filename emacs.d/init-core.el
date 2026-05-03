;;; init-core.el -*- lexical-binding: t; -*-
(message "[init-core] begin: PATH=%s" (getenv "PATH"))

(define-key global-map [?¥] [?\\])  ;; ¥→バックスラッシュ
(setq-default frame-title-format (format "%%b - emacs@%s" (system-name)))

;; 時計
;; モードラインの曜日・時刻表示を無効化
(display-time-mode 0)

;; ElDoc のマイナーモード名をモードラインから消す
(with-eval-after-load 'eldoc
  (setq minor-mode-alist (assq-delete-all 'eldoc-mode minor-mode-alist))
  (add-to-list 'minor-mode-alist '(eldoc-mode "")))

;; 括弧ハイライト
(show-paren-mode t)
(setq show-paren-delay 0
      show-paren-style 'expression)

;; 末尾空白を保存時に削除
(add-hook 'before-save-hook #'delete-trailing-whitespace)

;; ウィンドウ移動
(windmove-default-keybindings)
(setq windmove-wrap-around t)

;; よく使う全体設定（custom を使わない版）
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t
      make-backup-files nil
      case-fold-search t
      indent-tabs-mode nil
      transient-mark-mode t)

;; キーバインド
(global-set-key (kbd "M-g") #'goto-line)

;; フレームをピクセル単位できっちりリサイズ
(setq frame-resize-pixelwise t)

;; まず起動時フレーム（最初の1枚）に適用
(add-to-list 'initial-frame-alist '(width  . 80)) ;; 列数（必要なら 200 などに）
(add-to-list 'initial-frame-alist '(height . 100));; 行数

;; 以降に作る新フレームにも同じ既定を適用
(add-to-list 'default-frame-alist '(width  . 80))
(add-to-list 'default-frame-alist '(height . 100))

(put 'eval-expression 'disabled nil)
(put 'upcase-region 'disabled nil)

;; Node is provided by Home Manager/Nix. Keep Emacs in sync with PATH instead
;; of pinning a machine-local nvm path.
(when-let ((node (executable-find "node")))
  (add-to-list 'exec-path (file-name-directory node)))

;; Rust toolchain
(setenv "PATH" (concat (expand-file-name "~/.cargo/bin") ":" (getenv "PATH")))
(add-to-list 'exec-path (expand-file-name "~/.cargo/bin"))

(message "[init-core] end: exec-path=%S" exec-path)
(provide 'init-core)
