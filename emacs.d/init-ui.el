;;; init-ui.el -*- lexical-binding: t; -*-

;;--------------------------------------------------------------------------------
;; MoralerspaceNeonHW フォント（GUIのみ）
;;--------------------------------------------------------------------------------
(defvar my/moralerspace-family "Moralerspace Neon HWJPDOC")

(when (display-graphic-p)
  ;; フレームの標準フォント
  (set-frame-font (format "%s-%d" my/moralerspace-family 20) t t)

  ;; default/bold/italic を明示
  (set-face-attribute 'default nil
                      :family my/moralerspace-family
                      :weight 'normal
                      :height 200)
  (set-face-attribute 'bold nil
                      :font (font-spec :family my/moralerspace-family :weight 'bold))
  (set-face-attribute 'italic nil
                      :font (font-spec :family my/moralerspace-family :slant 'italic))
  (set-face-attribute 'bold-italic nil
                      :font (font-spec :family my/moralerspace-family :weight 'bold :slant 'italic))

  ;; CJK / 記号も同フォントに寄せる
  (dolist (cs '(japanese-jisx0208 kana han cjk-misc symbol))
    (set-fontset-font t cs (font-spec :family my/moralerspace-family) nil 'prepend)))

;; フェイス全体の配色（前景・背景）
(set-face-attribute 'default nil
                    :foreground "#E0E0E0"
                    :background "#1F1F1F")

;; 背景の透明度（GUIのみ）
(defvar my/frame-opacity 85)
(defvar my/frame-opacity-setting `(alpha . (,my/frame-opacity . ,my/frame-opacity)))

(defun my/apply-frame-opacity (&optional frame)
  (let ((target-frame (or frame (selected-frame))))
    (when (display-graphic-p target-frame)
      (set-frame-parameter target-frame
                           (car my/frame-opacity-setting)
                           (cdr my/frame-opacity-setting)))))

(add-to-list 'initial-frame-alist my/frame-opacity-setting)
(add-to-list 'default-frame-alist my/frame-opacity-setting)
(add-hook 'window-setup-hook #'my/apply-frame-opacity)
(add-hook 'after-make-frame-functions #'my/apply-frame-opacity)

;; 絵文字（Apple Color Emoji）
(ignore-errors
  (set-fontset-font nil '(#x1F000 . #x1FAFF) "Noto Color Emoji"))

;; macOS 絵文字／文字ビューア
(when (display-graphic-p)
  (global-set-key (kbd "C-M-SPC") #'ns-do-show-character-palette)
  (global-set-key (kbd "C-s-SPC") #'ns-do-show-character-palette))

;;--------------------------------------------------------------------------------
;; Powerline（テーマ色調整）
;;--------------------------------------------------------------------------------
(use-package powerline
  :config
  (powerline-default-theme)
  (setq ns-use-srgb-colorspace nil)
  (set-face-attribute 'mode-line nil :foreground "#000000" :background "#3399FF" :box nil)
  (set-face-attribute 'powerline-active1   nil :foreground "#000000" :background "#FFFF00" :inherit 'mode-line)
  (set-face-attribute 'powerline-active2   nil :foreground "#000000" :background "#FFFFFF" :inherit 'mode-line)
  (set-face-attribute 'powerline-inactive1 nil :foreground "#000000" :background "#FFFFFF" :inherit 'mode-line)
  (set-face-attribute 'powerline-inactive2 nil :foreground "#000000" :background "#FFFFFF" :inherit 'mode-line))

;;--------------------------------------------------------------------------------
;; フォントサイズ調整（Meta+↑/↓/0）
;;--------------------------------------------------------------------------------
(setq mac-command-modifier 'meta
      mac-option-modifier  'super
      mac-control-modifier 'control
      ns-function-modifier 'hyper)

(defun increase-font-size ()
  (interactive)
  (set-face-attribute 'default nil :height (+ 10 (face-attribute 'default :height))))
(defun decrease-font-size ()
  (interactive)
  (let ((h (face-attribute 'default :height)))
    (set-face-attribute 'default nil :height (if (<= h 10) h (- h 10)))))
(defun default-font-size ()
  (interactive)
  (set-face-attribute 'default nil :height 360))
(global-set-key (kbd "M-<up>")   #'increase-font-size)
(global-set-key (kbd "M-<down>") #'decrease-font-size)
(global-set-key (kbd "M-0")      #'default-font-size)


;;--------------------------------------------------------------------------------
;; cursor trail
;;--------------------------------------------------------------------------------
;; lolipop depends on a local native dylib. Keep it optional so this public
;; repository does not need to carry machine-specific binaries.
(let ((lolipop-dir (expand-file-name "lolipop/" user-emacs-directory)))
  (when (file-directory-p lolipop-dir)
    (add-to-list 'load-path lolipop-dir)
    (when (require 'lolipop-mode nil t)
      (setq lolipop-opacity 1.0)
      (setq lolipop-duration-scale 0.45)
      (lolipop-mode 1))))
