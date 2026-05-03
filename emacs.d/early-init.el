;; -*- lexical-binding: t; -*-
(setq package-enable-at-startup nil)

;; GUI Emacs でも Homebrew の PATH を使う
(let ((brew-bin "/opt/homebrew/bin"))
  (setenv "PATH" (concat brew-bin ":" (getenv "PATH")))
  (add-to-list 'exec-path brew-bin))

(let ((paths '("/opt/homebrew/opt/gcc/lib/gcc/current"
               "/opt/homebrew/opt/libgccjit/lib/gcc/current"
               "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib")))
  (setenv "LIBRARY_PATH"
          (mapconcat #'identity
                     (delete-dups
                      (append paths
                              (split-string (or (getenv "LIBRARY_PATH") "") ":" t)))
                     ":")))
