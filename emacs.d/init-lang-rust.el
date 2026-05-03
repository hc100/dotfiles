;;; init-lang-rust.el -*- lexical-binding: t; -*-

;;--------------------------------------------------------------------------------
;; Rust
;;--------------------------------------------------------------------------------
(defvar treesit-language-source-alist nil)

(add-to-list 'treesit-extra-load-path (expand-file-name "~/.emacs.d/tree-sitter"))

(add-to-list 'treesit-language-source-alist
             '(rust . ("https://github.com/tree-sitter/tree-sitter-rust")))

(when (fboundp 'rust-ts-mode)
  (add-to-list 'major-mode-remap-alist '(rust-mode . rust-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode)))

(defun my/rustfmt-buffer ()
  "Format current buffer with rustfmt."
  (interactive)
  (if-let ((rustfmt (executable-find "rustfmt")))
      (let ((point-pos (point))
            (formatted (generate-new-buffer " *rustfmt*")))
        (unwind-protect
            (if (zerop (call-process-region (point-min) (point-max)
                                            rustfmt nil formatted nil
                                            "--emit" "stdout"))
                (progn
                  (erase-buffer)
                  (insert-buffer-substring formatted)
                  (goto-char (min point-pos (point-max))))
              (message "[rust] rustfmt failed"))
          (kill-buffer formatted)))
    (message "[rust] rustfmt was not found in PATH")))

(defun my/rust-eglot-server ()
  "Return the current Eglot server for this buffer, if any."
  (when (fboundp 'eglot-current-server)
    (ignore-errors (eglot-current-server))))

(defun my/rust-ensure-eglot ()
  "Ensure Eglot is active for the current Rust buffer."
  (or (my/rust-eglot-server)
      (progn
        (eglot-ensure)
        (my/rust-eglot-server))))

(defun my/rust-format-buffer ()
  "Format current Rust buffer via Eglot when possible, else rustfmt."
  (interactive)
  (if (my/rust-ensure-eglot)
      (eglot-format-buffer)
    (my/rustfmt-buffer)))

(defun my/rust-import-action (&optional organize)
  "Apply Rust import-related code action.
With prefix ORGANIZE, organize imports for the whole buffer."
  (interactive "P")
  (cond
   ((not (my/rust-ensure-eglot))
    (message "[rust] Eglot is starting in background. Run C-c o again in a moment"))
   (organize
    (eglot-code-action-organize-imports (point-min) (point-max)))
   ((fboundp 'eglot-code-action-quickfix)
    (call-interactively #'eglot-code-action-quickfix))
   (t
    (call-interactively #'eglot-code-actions))))

(defun my/rust-mode-setup ()
  "Rust mode defaults."
  (setq-local indent-tabs-mode nil
              tab-width 4)
  (add-hook 'before-save-hook #'my/rust-format-buffer nil t)
  (local-set-key (kbd "C-c =") #'my/rust-format-buffer)
  (local-set-key (kbd "C-c o") #'my/rust-import-action)
  (unless (treesit-language-available-p 'rust)
    (message "[rust] tree-sitter grammar for Rust is missing. Run M-x treesit-install-language-grammar RET rust")))

(add-hook 'rust-ts-mode-hook #'my/rust-mode-setup)
(add-hook 'rust-mode-hook #'my/rust-mode-setup)

(provide 'init-lang-rust)
