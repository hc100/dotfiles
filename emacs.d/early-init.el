;; -*- lexical-binding: t; -*-
(setq package-enable-at-startup nil)

;; GUI Emacs does not necessarily inherit the login shell PATH. Add the Nix
;; profiles first so straight.el can find the Nix-managed git on every Mac.
(let* ((user (or (getenv "USER") user-login-name))
       (paths (list "/run/current-system/sw/bin"
                    (format "/etc/profiles/per-user/%s/bin" user)
                    "/nix/var/nix/profiles/default/bin"
                    "/opt/homebrew/bin"
                    "/opt/homebrew/sbin"))
       (existing (split-string (or (getenv "PATH") "") path-separator t))
       (merged (delete-dups (append paths existing))))
  (setenv "PATH" (mapconcat #'identity merged path-separator))
  (setq exec-path (append paths exec-path)))

(let ((paths '("/opt/homebrew/opt/gcc/lib/gcc/current"
               "/opt/homebrew/opt/libgccjit/lib/gcc/current"
               "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib")))
  (setenv "LIBRARY_PATH"
          (mapconcat #'identity
                     (delete-dups
                      (append paths
                              (split-string (or (getenv "LIBRARY_PATH") "") ":" t)))
                     ":")))
