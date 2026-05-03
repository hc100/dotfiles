;;; init-lsp.el -*- lexical-binding: t; -*-

;;--------------------------------------------------------------------------------
;; Diagnostics
;;--------------------------------------------------------------------------------
(use-package flycheck
  :delight flycheck-mode
  :hook (vue-mode . flycheck-mode)
  :config
  ;; vue-mode では eslint_d を優先する
  (setq flycheck-javascript-eslint-executable "eslint_d"))

;;--------------------------------------------------------------------------------
;; Eglot コア設定（共通）
;;--------------------------------------------------------------------------------
(use-package eglot
  :straight nil
  :commands (eglot eglot-ensure)
  :hook ((go-mode . eglot-ensure)
         (go-ts-mode . eglot-ensure)
         (go-dot-mod-mode . eglot-ensure)
         (go-dot-work-mode . eglot-ensure)
         (rust-mode . eglot-ensure)
         (rust-ts-mode . eglot-ensure)
         (php-mode . eglot-ensure)
         (tsx-ts-mode . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (js-ts-mode . eglot-ensure)
         (json-ts-mode . eglot-ensure)
         (css-ts-mode . eglot-ensure)
         (eglot-managed-mode . my/eglot-managed-mode-setup))
  :init
  (setq eglot-autoshutdown t
        eglot-sync-connect nil
        eglot-send-changes-idle-time 0.2
        eglot-events-buffer-size 0)
  :config
  ;; 既存利用サーバを優先し、language id も明示しておく
  (dolist (entry
           '(((php-mode php-ts-mode) . ("intelephense" "--stdio"))
             ((rust-mode rust-ts-mode) . ("rust-analyzer"))
             (((go-mode :language-id "go")
               (go-ts-mode :language-id "go")
               (go-dot-mod-mode :language-id "go.mod")
               (go-mod-ts-mode :language-id "go.mod")
               (go-dot-work-mode :language-id "go.work")
               (go-work-ts-mode :language-id "go.work"))
              . ("gopls"))
             (((js-mode :language-id "javascript")
               (js-ts-mode :language-id "javascript")
               (tsx-ts-mode :language-id "typescriptreact")
               (typescript-ts-mode :language-id "typescript")
               (typescript-mode :language-id "typescript"))
              . ("typescript-language-server" "--stdio"))))
    (add-to-list 'eglot-server-programs entry))
  (setq-default
   eglot-workspace-configuration
   '((:gopls .
      ((gofumpt . t)
       (linksInHover . t)
       (completeUnimported . t)
       (directoryFilters . ["-node_modules" "-vendor"])
       (analyses .
                  ((nilness . t)
                   (shadow . t)
                   (unusedparams . t)
                   (unusedwrite . t)
                   (useany . t)))))
     (:rust-analyzer .
      ((cargo . ((allFeatures . t)))
       (checkOnSave . t)
       (check . ((command . "clippy")))))
     (:intelephense .
      ((telemetry . (:enabled :json-false)))))))

(defun my/eglot-managed-mode-setup ()
  "Keep completion, xref and diagnostics consistent for Eglot buffers."
  (eldoc-mode 1)
  (flymake-mode 1)
  (when (and (fboundp 'cape-capf-buster)
             (fboundp 'cape-file)
             (fboundp 'cape-dabbrev)
             (fboundp 'eglot-completion-at-point))
    (setq-local completion-at-point-functions
                (list (cape-capf-buster #'eglot-completion-at-point)
                      #'cape-file
                      #'cape-dabbrev)))
  (when (bound-and-true-p flycheck-mode)
    (flycheck-mode -1)))

;;--------------------------------------------------------------------------------
;; 操作系
;;--------------------------------------------------------------------------------
(defun my/eglot-show-doc-buffer ()
  "Show documentation for symbol at point in a help buffer."
  (interactive)
  (if (fboundp 'eldoc-doc-buffer)
      (eldoc-doc-buffer)
    (eldoc)))

(defun my/eglot-import-action (&optional organize)
  "Run an import-related action appropriate for the current language.
With prefix ORGANIZE, force organize-imports for the whole buffer."
  (interactive "P")
  (cond
   ((derived-mode-p 'rust-ts-mode 'rust-mode)
    (cond
     ((not (ignore-errors (eglot-current-server)))
      (eglot-ensure)
      (message "[rust] Eglot is starting in background. Run C-c o again in a moment"))
     (organize
      (eglot-code-action-organize-imports (point-min) (point-max)))
     ((fboundp 'eglot-code-action-quickfix)
      (call-interactively #'eglot-code-action-quickfix))
     (t
      (call-interactively #'eglot-code-actions))))
   ((bound-and-true-p eglot-managed-mode)
    (eglot-code-action-organize-imports (point-min) (point-max)))
   (t
    (message "[eglot] Eglot is not active"))))

(with-eval-after-load 'eglot
  (define-key eglot-mode-map (kbd "C-c r") #'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c a") #'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c d") #'my/eglot-show-doc-buffer)
  (define-key eglot-mode-map (kbd "C-c o") #'my/eglot-import-action)
  (define-key eglot-mode-map (kbd "C-c =") #'eglot-format-buffer))

;;--------------------------------------------------------------------------------
;; 共通パフォーマンス調整
;;--------------------------------------------------------------------------------
(setq gc-cons-threshold (* 256 1024 1024))
(setq read-process-output-max (* 4 1024 1024))  ;; Emacs 27.1+

(run-with-idle-timer
 5 nil
 (lambda ()
   (setq gc-cons-threshold (* 64 1024 1024))))

(provide 'init-lsp)
