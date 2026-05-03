;;; init-utils.el -*- lexical-binding: t; -*-

;;--------------------------------------------------------------------------------
;; 便利系
;;--------------------------------------------------------------------------------
(use-package yaml-mode :mode "\\.ya?ml\\'")
(use-package ag        :commands ag)
(use-package wgrep-ag  :after ag
  :config (setq default-process-coding-system '(utf-8 . utf-8)
                ag-highlight-search t
                ag-reuse-buffers t)
  :hook (ag-mode . (lambda ()
                     (setq wgrep-enable-key "r")
                     (wgrep-ag-setup))))
(use-package which-key
  :delight which-key-mode
:hook (after-init . which-key-mode))
(use-package htmlize   :commands htmlize-buffer)
(use-package helm-projectile :after (helm projectile))

;;--------------------------------------------------------------------------------
;; Projectile / FFIP（ripgrep+fd を利用）
;;--------------------------------------------------------------------------------
(use-package projectile
  :delight projectile-mode
  :demand t
  :init (setq projectile-indexing-method 'alien
              projectile-project-search-path '("~/dev/src/github.com/"))
  :config
  (projectile-mode +1)
  ;; 除外
  (dolist (d '("vendor" "node_modules" "storage" "database" "resources" ".git"))
    (add-to-list 'projectile-globally-ignored-directories d))
  (add-to-list 'projectile-globally-ignored-files "composer.lock")
  (add-to-list 'projectile-globally-ignored-file-suffixes "min.js")
  :bind-keymap ("C-c p" . projectile-command-map))

(with-eval-after-load 'project
  ;; 同一Gitリポジトリ内でも、`.project` があればそこを別プロジェクトのrootにする
  (add-to-list 'project-vc-extra-root-markers ".project"))

(use-package find-file-in-project
  :after projectile
  :bind (("C-c f" . find-file-in-project))
  :config (setq ffip-use-rust-fd t
                ffip-project-root-function #'projectile-project-root))

;;--------------------------------------------------------------------------------
;; F#
;;--------------------------------------------------------------------------------
(use-package fsharp-mode
  :defer t)

;; emoji-fontset があれば使う（存在しない環境でもエラーにしない）
(ignore-errors
  (when (require 'emoji-fontset nil t)
    (emoji-fontset-enable "Apple Color Emoji")))

;;--------------------------------------------------------------------------------
;; Xref とジャンプ補助（括弧ジャンプ）
;;--------------------------------------------------------------------------------
(defun paren-match (&optional arg)
  "If on paren, jump to its match. With numeric ARG(1..99), jump to ARG% of buffer."
  (interactive "P")
  (cond
   ((numberp arg)
    (unless (and (>= arg 1) (<= arg 99))
      (user-error "Prefix must be between 1 and 99"))
    (goto-char (floor (* (point-max) (/ (float arg) 100.0))))
    (back-to-indentation))
   ((and (char-after) (eq (char-syntax (char-after)) ?\()) (forward-list 1) (backward-char 1))
   ((and (> (point) (point-min)) (eq (char-syntax (char-before)) ?\))) (backward-list 1))
   (t (user-error "Place point on a parenthesis/bracket/brace"))))
(define-key ctl-x-map (kbd "%") #'paren-match)

;;--------------------------------------------------------------------------------
;; Shell
;;--------------------------------------------------------------------------------
(setq shell-file-name "/bin/bash"
      explicit-shell-file-name "/bin/bash")

;;--------------------------------------------------------------------------------
;; tramp
;;--------------------------------------------------------------------------------
(setq tramp-auto-save-directory "/tmp")

;;--------------------------------------------------------------------------------
;; auto-revert の監視対象から重いディレクトリを除外
;;--------------------------------------------------------------------------------
(with-eval-after-load 'autorevert
  (setq auto-revert-use-notify t)
  (setq auto-revert-notify-exclude-dir-regexp
        (rx string-start
            (or "node_modules" "vendor" "storage")
            (or "/" string-end))))

;;--------------------------------------------------------------------------------
;; 現在開いているファイルの絶対パスを kill-ring にコピーするカスタム関数
;;--------------------------------------------------------------------------------
(defun my/copy-current-file-path ()
  "Copy the full path of the current buffer's file to the kill ring."
  (interactive)
  (if-let ((file (buffer-file-name)))
      (progn
        (kill-new file)
        (message "Copied file path: %s" file))
    (message "This buffer is not visiting a file.")))

;; 任意のキーバインド（例: C-c p）
(global-set-key (kbd "C-c p") #'my/copy-current-file-path)

;;--------------------------------------------------------------------------------
;; Codex: 選択範囲の説明をミニバッファに表示する
;;--------------------------------------------------------------------------------
(require 'subr-x)

(defgroup my/codex-explain nil
  "選択範囲を Codex で説明するための設定。"
  :group 'tools)

(defcustom my/codex-explain-command "codex"
  "Codex 実行コマンド名。"
  :type 'string
  :group 'my/codex-explain)

(when (listp my/codex-explain-command)
  (setq my/codex-explain-command (car my/codex-explain-command)))

(defcustom my/codex-explain-max-length 300
  "ミニバッファ表示時に出力を切り詰める最大文字数。"
  :type 'integer
  :group 'my/codex-explain)

;; プロジェクトのルートを分かる範囲で取得する
(defun my/codex-explain--repo-root ()
  (let ((root nil))
    (when (and (fboundp 'projectile-project-root)
               (ignore-errors (setq root (projectile-project-root)))))
    (unless root
      (when (fboundp 'project-current)
        (let ((proj (project-current nil)))
          (when proj
            (setq root (project-root proj))))))
    (unless root
      (when (fboundp 'vc-root-dir)
        (setq root (vc-root-dir))))
    root))

;; Codex に渡す説明依頼文を組み立てる
(defun my/codex-explain--build-prompt (selection file repo)
  (format
   (concat
    "以下のコードについて日本語で簡潔に説明してください。\n"
    "必要なら前提や注意点も補足してください。\n\n"
    "# ファイル: %s\n"
    "# リポジトリ: %s\n\n"
    "```\n%s\n```\n")
   file
   (or repo "不明")
   selection))

;; 選択範囲を Codex に説明させ、結果をミニバッファに表示する
(defun my/codex-explain-region ()
  (interactive)
  ;; リージョンが選択されていることを保証する
  (unless (use-region-p)
    (user-error "説明してほしい範囲を選択してください"))
  ;; Codex コマンドが見つかることを保証する
  (unless (executable-find my/codex-explain-command)
    (user-error "Codex コマンドが見つかりません: %s" my/codex-explain-command))
  (let* ((selection (buffer-substring-no-properties
                     (region-beginning)
                     (region-end)))
         (file (or (buffer-file-name) (buffer-name)))
         (repo (my/codex-explain--repo-root))
         (prompt (my/codex-explain--build-prompt selection file repo))
         (input-file (make-temp-file "codex-explain-input-" nil ".txt"))
         (output-file (make-temp-file "codex-explain-" nil ".txt"))
         (default-directory (or repo default-directory))
         (output-buffer (generate-new-buffer " *codex-explain-output*"))
         (exit-code nil)
         (result nil))
    (unwind-protect
        (progn
          ;; 標準入力用の一時ファイルにプロンプトを保存する
          (with-temp-file input-file
            (insert prompt))
          (setq exit-code
                (call-process
                 my/codex-explain-command
                 input-file
                 output-buffer
                 nil
                 "exec"
                 "--output-last-message"
                 output-file
                 "-"))
          (if (and (numberp exit-code)
                   (= exit-code 0)
                   (file-exists-p output-file))
              (setq result
                    (string-trim
                     (with-temp-buffer
                       (insert-file-contents output-file)
                       (buffer-string))))
            (setq result
                  (format "Codex 実行に失敗しました: %s"
                          (string-trim
                           (with-current-buffer output-buffer
                             (buffer-string)))))))
      (when (file-exists-p output-file)
        (delete-file output-file))
      (when (file-exists-p input-file)
        (delete-file input-file))
      (when (buffer-live-p output-buffer)
        (kill-buffer output-buffer)))
    (if (and result
             (> (length result) my/codex-explain-max-length))
        (message "%s..." (substring result 0 my/codex-explain-max-length))
      (message "%s" result))))

;; キーバインド: C-c c e
(global-set-key (kbd "C-c c e") #'my/codex-explain-region)

;;--------------------------------------------------------------------------------
;; Aider（GitHub 直レシピ）
;;--------------------------------------------------------------------------------
(use-package aider
  :straight (:host github :repo "tninja/aider.el" :files ("aider.el"))
  :bind (("C-c a" . aider-transient-menu))
  :config
  ;; モデルや API キーは環境変数側で設定してください
  (setq aider-args '("--no-auto-commits" "--model" "gpt-4o-mini")))

(provide 'init-utils)
