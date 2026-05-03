;;; init-lang-web.el -*- lexical-binding: t; -*-

;;--------------------------------------------------------------------------------
;; Web/JS/Vue 周り
;;--------------------------------------------------------------------------------
(use-package web-mode
  :mode (("\\.html?\\'" . web-mode)
         ("\\.css\\'"   . web-mode)
         ("\\.js\\'"    . web-mode))
  :init
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset    2
        web-mode-code-indent-offset   2))

(use-package vue-mode
  :mode "\\.vue\\'"
  :init
  (setq mmm-js-mode-enter-hook  (lambda () (setq syntax-ppss-table nil)))
  (setq mmm-typescript-mode-enter-hook (lambda () (setq syntax-ppss-table nil))))

(use-package add-node-modules-path
  :hook ((vue-mode . add-node-modules-path)))

(use-package prettier-js
  :hook ((vue-mode . prettier-js-mode)))

(use-package eslint-fix
  :commands eslint-fix)

(with-eval-after-load 'vue-mode
  (add-hook 'after-save-hook #'eslint-fix))

;;--------------------------------------------------------------------------------
;; Treesit (TypeScript/TSX)
;;--------------------------------------------------------------------------------
(setq treesit-language-source-alist
      '((typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" nil "typescript/src"))
        (tsx        . ("https://github.com/tree-sitter/tree-sitter-typescript" nil "tsx/src"))))
(add-to-list 'treesit-extra-load-path (expand-file-name "~/.emacs.d/tree-sitter"))
(add-to-list 'auto-mode-alist '("\\.ts\\'"  . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'major-mode-remap-alist '(typescript-mode . typescript-ts-mode))

;; 現在のプロジェクトの node_modules/.bin を exec-path に追加
(defun my/add-project-node-bin-to-path ()
  (when-let* ((proj (project-current))
              (root (expand-file-name (project-root proj)))
              (bin  (expand-file-name "node_modules/.bin" root)))
    (when (file-directory-p bin)
      (add-to-list 'exec-path bin)
      (let* ((path (getenv "PATH"))
             (sep  path-separator)
             (parts (delete-dups (split-string path sep t)))
             (new   (string-join (cons bin (remove bin parts)) sep)))
        (setenv "PATH" new)))))
(add-hook 'tsx-ts-mode-hook #'my/add-project-node-bin-to-path)
(add-hook 'typescript-ts-mode-hook #'my/add-project-node-bin-to-path)
(add-hook 'js-ts-mode-hook #'my/add-project-node-bin-to-path)
(add-hook 'find-file-hook #'my/add-project-node-bin-to-path)

;;--------------------------------------------------------------------------------
;; Next.js / TSX 用モード設定
;;--------------------------------------------------------------------------------
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'"  . js-ts-mode))

;; Emmet (JSX 内で 'div>ul>li*3' 的な補完)
(use-package emmet-mode
  :hook ((tsx-ts-mode js-ts-mode typescript-ts-mode) . emmet-mode)
  :config (setq emmet-expand-jsx-className? t))

;; 保存時自動修正（eslint_d --fix）
(defun my/nextjs-eslint-fix-buffer ()
  "Run eslint_d --fix on current file if eslint config exists."
  (interactive)
  (when (and buffer-file-name
             (locate-dominating-file
              buffer-file-name
              (lambda (d)
                (directory-files d nil "^\\.eslintrc\\|^\\.eslintrc\\..*\\|^eslint\\.config\\.[cm]?js$"))))
    (call-process "eslint_d" nil "*eslint_d*" nil "--fix" buffer-file-name)))

(add-hook 'before-save-hook #'my/nextjs-eslint-fix-buffer)

;; Prettier との棲み分け（最後に整形）
;; (use-package apheleia
;;   :config
;;   (setf (alist-get 'prettier apheleia-formatters)
;;         '("npx" "prettier" "--stdin-filepath" filepath))
;;   (dolist (mode '(tsx-ts-mode typescript-ts-mode js-ts-mode json-ts-mode css-ts-mode))
;;     (add-to-list 'apheleia-mode-alist (cons mode 'prettier)))
;;   (apheleia-global-mode +1))

;; ---- 実行・テスト・コンパイル ----
(defun my/nextjs-dev ()
  "Run next dev in project root."
  (interactive)
  (let* ((root (or (project-root (project-current)) default-directory)))
    (compile (format "cd %s && pnpm dev" root))))
(global-set-key (kbd "<f5>") #'my/nextjs-dev)

(defun my/jest-file ()
  "Run jest for current file."
  (interactive)
  (let* ((root (or (project-root (project-current)) default-directory))
         (file (file-relative-name buffer-file-name root)))
    (compile (format "cd %s && pnpm jest -- %s" root file))))

(provide 'init-lang-web)
