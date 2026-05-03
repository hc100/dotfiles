;;; init.el --- straight.el unified setup -*- lexical-binding: t; -*-
;; -*- Mode: Emacs-Lisp ; Coding: utf-8 -*-

(add-to-list 'load-path "~/.emacs.d/elisp/")
(load (expand-file-name "init-core.el" user-emacs-directory))
(load (expand-file-name "init-packages.el" user-emacs-directory))
(load (expand-file-name "init-ui.el" user-emacs-directory))
(load (expand-file-name "init-completion.el" user-emacs-directory))
(load (expand-file-name "init-lsp.el" user-emacs-directory))
(load (expand-file-name "init-lang-go.el" user-emacs-directory))
(load (expand-file-name "init-lang-rust.el" user-emacs-directory))
(load (expand-file-name "init-lang-web.el" user-emacs-directory))
(load (expand-file-name "init-lang-php.el" user-emacs-directory))
(load (expand-file-name "init-vcs.el" user-emacs-directory))
(load (expand-file-name "init-utils.el" user-emacs-directory))

;;; init.el ends here
