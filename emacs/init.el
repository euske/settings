;; -*- coding: utf-8 -*-
;; .emacs 26 for euske


;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

;(set-language-environment "utf-8")
(cd "~/")
(global-font-lock-mode t)


;;  Appearance settings
;;
(defun is-using-screen ()
  (and (not window-system) (string-equal "screen" (getenv "TERM"))))

(defun change-screen-title (s) (interactive "sTitle: ")
  (if (is-using-screen)
      (send-string-to-terminal (concat "\033k" s "\033\134"))))

(if window-system
    (progn
      (setq visible-bell t)
      (server-start)
      (menu-bar-mode -1)
      (tool-bar-mode -1)
      (scroll-bar-mode -1))
  (progn
    ;; screen/tmux
    (setq visible-bell nil)
    (set-terminal-coding-system 'utf-8)
    (menu-bar-mode -1)
    (defun display-window-title () (interactive) (change-screen-title "Emacs"))
    (add-hook 'suspend-resume-hook (function display-window-title))
    (display-window-title)
    (set-face-foreground 'mode-line (getenv "HOST_COLOR"))
    ))


;;  General
;;
(put 'eval-expression 'disabled nil)
(prefer-coding-system 'utf-8-dos)
(add-to-list 'load-path "~/lib/emacs")
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq-default indent-tabs-mode nil)
(setq next-line-add-newlines nil
      font-lock-maximum-decoration t
      inhibit-startup-message t
      require-final-newline t
      auto-save-list-file-prefix nil
      suggest-key-bindings nil
      dired-listing-switches "-ao"
;      scroll-conservatively 1
      create-lockfiles nil
      make-backup-files nil
      )


;;  find-exist-file
;;
(defun find-exist-file (fname) (interactive "fFind exist file: ")
  (if (car (file-attributes
            (file-chase-links (expand-file-name fname))))
      (dired fname)
    (find-file fname)))
(global-set-key "\C-x\C-f" 'find-exist-file)
(global-set-key "\C-xF"    'find-file)


;;  display-time
;;
(setq display-time-24hr-format t)
(display-time)
(line-number-mode 1)
(column-number-mode 1)


;;  Encoding operation
;;
(defun euc () (interactive) (set-buffer-file-coding-system 'euc-jp-unix))
(defun jis () (interactive) (set-buffer-file-coding-system 'iso-2022-jp-unix))
(defun sjis () (interactive) (set-buffer-file-coding-system 'sjis-dos))
(defun utf () (interactive) (set-buffer-file-coding-system 'utf-8-unix))
(defun dos () (interactive) (set-buffer-file-coding-system 'utf-8-with-signature-dos))


;;  tabs-spaces
;;
(defun untabify-at-save ()
       (save-excursion
         (goto-char (point-min))
         (while (re-search-forward "[ \t]+$" nil t)
           (delete-region (match-beginning 0) (match-end 0)))
         (goto-char (point-min))
         (if (search-forward "\t" nil t)
             (untabify (1- (point)) (point-max))))
       nil)


;;  Japanese input method
;;
(add-to-list 'load-path "~/lib/emacs/skk")
(defvar skk-isearch-switch t)
(require 'skk "skk")
(global-set-key "\C-x\C-j" 'skk-mode)


;;  Python
;;
(add-hook 'python-mode-hook
          (function (lambda ()
                      (define-key python-mode-map "\C-m" 'newline-and-indent)
                      (if (zerop (buffer-size))
                          (insert-file "~/lib/python/python-template.py")))))


;;  C/C++/ObjC
;;
(defvar c-default-style nil)
(c-add-style "me"
             '("Java"
               (c-offsets-alist . (
                                   (arglist-cont . c-lineup-argcont)
                                   (arglist-intro . +)
                                   ))
               ))
;(add-to-list 'auto-mode-alist '("\\.h$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.m$" . objc-mode))
(add-to-list 'c-default-style '(c-mode . "stroustrup"))
(add-to-list 'c-default-style '(c++-mode . "stroustrup"))
(add-to-list 'c-default-style '(objc-mode . "stroustrup"))
(add-to-list 'c-default-style '(java-mode . "me"))


;;  C#
;;
(defvar c-default-style nil)
(autoload 'csharp-mode "csharp-mode" "Major mode for editing C# code." t)
(add-to-list 'auto-mode-alist '("\\.cs$" . csharp-mode))
(add-to-list 'c-default-style '(csharp-mode . "me"))


;;  Java
;;
(add-hook 'java-mode-hook
          (function (lambda ()
                      (make-local-variable 'write-contents-hooks)
                      (add-hook 'write-contents-hooks 'untabify-at-save))))


;;  Rust
;;
(autoload 'rust-mode "rust-mode" "Major mode for Rust language." t)
(add-to-list 'auto-mode-alist '("\\.rs$" . rust-mode))


;;  TypeScript
;;
(autoload 'typescript-mode "typescript-mode" "Major mode for TypeScript language." t)
(add-to-list 'auto-mode-alist '("\\.ts$" . typescript-mode))


;;  XML
;;
(add-hook 'nxml-mode-hook
          (function (lambda ()
                      (define-key nxml-mode-map "\M-h" 'backward-kill-word))))


;;  HTML
;;
(defun html-convert-region (x y) (interactive "r")
  (let ((m (set-marker (make-marker) y)))
    (save-excursion
      (goto-char x)
      (while (search-forward "&" m t) (replace-match "&amp;" t t))
      (goto-char x)
      (while (search-forward ">" m t) (replace-match "&gt;" t t))
      (goto-char x)
      (while (search-forward "<" m t) (replace-match "&lt;" t t))
      )))

(defun html-insert-tag (begin end tag &optional attrs conv save)
  (let ((b (set-marker (make-marker) begin))
        (e (set-marker (make-marker) end))
        (a (if (stringp attrs) (concat " " attrs) "")))
    (if conv (html-convert-region begin end))
    (goto-char b) (insert (concat "<" tag a ">"))
    (goto-char e) (insert (concat "</" tag ">"))
    (if save (goto-char e))
    b))

(defun pre (begin end) (interactive "r")
  (let ((e (set-marker (make-marker) end)))
    (html-convert-region begin e)
    (goto-char begin) (insert "<blockquote><pre>\n")
    (goto-char e) (insert "</pre></blockquote>\n")))

(setq html-mode-map (make-sparse-keymap))
(define-key html-mode-map "\C-cb"
  (function (lambda (b e) (interactive "r")
              (html-insert-tag
               (html-insert-tag b e "span" "class=bl")
               (point) "nobr"))))
(define-key html-mode-map "\C-cr"
  (function (lambda (b e) (interactive "r")
              (html-insert-tag b e "span" "class=comment"))))
(define-key html-mode-map "\C-cs"
  (function (lambda (b e) (interactive "r")
              (html-insert-tag b e "strong"))))
(define-key html-mode-map "\C-cu"
  (function (lambda (b e) (interactive "r")
              (html-insert-tag b e "u"))))
(define-key html-mode-map "\C-ce"
  (function (lambda (b e) (interactive "r")
              (html-insert-tag b e "em"))))
(define-key html-mode-map "\C-cc"
  (function (lambda (b e) (interactive "r")
              (html-insert-tag b e "code" nil t))))
(define-key html-mode-map "\C-ck"
  (function (lambda (b e) (interactive "r")
              (html-insert-tag b e "kbd" nil t))))
(define-key html-mode-map "\C-cm"
  (function (lambda (b e) (interactive "r")
              (html-insert-tag b e "mark" nil t))))

;; timestamps
(add-hook 'html-mode-hook
          (function (lambda ()
                      (set (make-local-variable 'electric-indent-mode) nil)
                      (add-hook 'local-write-file-hooks 'html-update-timestamp))))
(defvar html-helper-timestamp-start "<!-- hhmts start -->\n")
(defvar html-helper-timestamp-end "<!-- hhmts end -->")
(defun html-update-timestamp ()
  "Basic function for updating timestamps. It finds the timestamp in
the buffer by looking for html-helper-timestamp-start, deletes all text
up to html-helper-timestamp-end, and runs html-helper-timestamp-hook
which will presumably insert an appropriate timestamp in the buffer."
  (save-excursion
    (goto-char (point-max))
    (if (not (search-backward html-helper-timestamp-start nil t))
        (message "timestamp delimiter start was not found")
      (let ((ts-start (+ (point) (length html-helper-timestamp-start)))
            (ts-end (if (search-forward html-helper-timestamp-end nil t)
                        (- (point) (length html-helper-timestamp-end))
                      nil)))
        (if (not ts-end)
            (message "timestamp delimiter end was not found. Type C-c C-t to insert one.")
          (delete-region ts-start ts-end)
          (goto-char ts-start)
          (run-hooks 'html-helper-timestamp-hook)))))
  nil)
(defun my-html-timestamp ()
  (insert "Last Modified: ")
  (call-process "env" nil t nil "date" "-u"))
(setq html-helper-timestamp-hook (function my-html-timestamp))


;;  Other key bindings
;;
(global-unset-key "\C-j")
(global-unset-key "\C-\]")
(global-unset-key [insert])
(global-unset-key [insertchar])
(global-unset-key "\C-xm")
(global-unset-key "\C-xt")
(global-unset-key "\C-x\C-p")
(global-unset-key "\C-x\C-n")
(global-unset-key "\C-x\C-l")
(global-unset-key "\C-\\")
(global-set-key "\M-r" 'query-replace-regexp)
(global-set-key "\C-s" 'isearch-forward-regexp)
(global-set-key "\C-r" 'isearch-backward-regexp)
(global-set-key "\M-l" 'goto-line)
(global-set-key "\M-c" 'goto-char)
(global-set-key "\C-xV" 'set-variable)
(global-set-key "\M-\C-w" 'kill-ring-save)
(global-set-key "\C-h\C-a" 'apropos)
(global-set-key "\C-h\C-v" 'apropos-variable)
(define-key minibuffer-local-map "\C-p" 'previous-history-element)
(define-key minibuffer-local-map "\C-n" 'next-history-element)
(define-key minibuffer-local-completion-map "\C-p" 'previous-history-element)
(define-key minibuffer-local-completion-map "\C-n" 'next-history-element)
(define-key minibuffer-local-ns-map "\C-p" 'previous-history-element)
(define-key minibuffer-local-ns-map "\C-n" 'next-history-element)
(define-key minibuffer-local-must-match-map "\C-p" 'previous-history-element)
(define-key minibuffer-local-must-match-map "\C-n" 'next-history-element)
; C-h <- Delete,  C-t <- C-h
(setq key-translation-map (make-sparse-keymap))
(define-key key-translation-map "\C-t" "\C-h")
(define-key key-translation-map "\C-h" "\C-\?")
(global-set-key "\M-h" 'backward-kill-word)
; for screen
(define-key key-translation-map "\M-OM" "\C-j")
(define-key key-translation-map "\M-[A" [up])
(define-key key-translation-map "\M-[B" [down])
(define-key key-translation-map "\M-[C" [right])
(define-key key-translation-map "\M-[D" [left])


;;  Misc. functions
;;
(defun iterate-line (f begin end)
  "Apply a given function at beginning of each lines of the region."
  (let ((m (set-marker (make-marker) end)))
    (goto-char begin)
    (while (< (point) m)
      (beginning-of-line)
      (funcall f m)
      (forward-line 1))))

(defun eval-region-message (begin end) (interactive "r")
  (eval-region begin end) (message "Eval done."))
(global-set-key "\C-x\C-e" 'eval-region-message)

(defun elmacro (begin end) (interactive "r")
  (iterate-line (function (lambda (m) (save-excursion (call-last-kbd-macro))))
                begin end))

(defun elinsert (begin end) (interactive "r")
  (let ((s (read-from-minibuffer "String: ")))
    (iterate-line (function (lambda (m) (insert s)))
                  begin end)))

(defun dediff (begin end) (interactive "r")
  (iterate-line (function (lambda (m)
                            (if (search-forward-regexp "^\\(\\+ \\|- \\|> \\|< \\)" m t)
                                (replace-match "" t t))))
                begin end))

(defun tab (n) (interactive "nTab-width: ")
  (setq tab-width n) (message "Tab-width is %d." n))

(defun tmp () (interactive)
  (switch-to-buffer "*scratch*") (lisp-interaction-mode))

(defun wc (x y) (interactive "r")
  (message "%d characters." (abs (- x y))))

(defun uuid () (interactive)
       (call-process "uuid" nil t nil))

(defun clipget () (interactive)
       (call-process "clipget" nil t t))

(defun xclip () (interactive)
  (set-mark-command nil)
  (let ((s (with-current-buffer (get-buffer-create " *xclip*")
             (erase-buffer)
             (set-buffer-multibyte nil)
             (buffer-disable-undo)
             (auto-save-mode -1)
             (call-process "xclip" nil t t "-out")
             (buffer-substring-no-properties (point-min) (point-max)))))
    (insert (decode-coding-string s 'utf-8))))


;;  Customization
;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(browse-url-netscape-program "firefox")
 '(csharp-want-flymake-fixup nil)
 '(csharp-want-imenu nil)
 '(csharp-want-yasnippet-fixup nil)
 '(js-indent-level 2)
 '(skk-cdb-large-jisyo "~/lib/skk/SKK-JISYO.L.cdb")
 '(skk-rom-kana-rule-list
   '(("hh" "h"
      ("ッ" . "っ"))
     ("mm" "m"
      ("ン" . "ん"))
     ("nn" "n"
      ("ン" . "ん"))
     ("?" nil "?")
     ("@" nil "@")
     ("$" nil "$")
     (";" nil ";")
     (":" nil ":")
     ("z[" nil "『")
     ("z]" nil "』")
     ("z{" nil
      ("【" . "【"))
     ("z}" nil
      ("】" . "】"))
     ("z`" nil
      ("“" . "“"))
     ("z'" nil
      ("”" . "”"))
     ("z." nil
      ("・" . "・"))
     ("z:" nil
      ("…" . "…"))
     ("z~" nil
      ("〜" . "〜"))
     ("z>" nil
      ("→" . "→"))
     ("z<" nil
      ("←" . "←"))
     ("z^" nil
      ("↑" . "↑"))
     ("zv" nil
      ("↓" . "↓"))
     ("z*" nil
      ("※" . "※"))
     ("z-" nil
      ("−" . "−"))
     ("z@" nil
      ("＠" . "＠"))
     ("z/" nil
      ("／" . "／"))
     ("z " nil
      ("　" . "　"))))
 '(skk-share-private-jisyo t)
 '(transient-mark-mode nil)
 '(typescript-indent-switch-clauses nil))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-comment-face ((((type tty pc) (class color) (background dark)) (:foreground "green"))))
 '(font-lock-doc-face ((t (:inherit font-lock-comment-face))))
 '(font-lock-function-name-face ((((type tty) (class color)) (:foreground "cyan"))))
 '(font-lock-keyword-face ((((type tty) (class color)) (:foreground "yellow"))))
 '(font-lock-string-face ((((type tty) (class color)) (:foreground "plum1"))))
 '(font-lock-type-face ((t (:foreground "cyan"))))
 '(font-lock-variable-name-face ((((type tty) (class color)) (:foreground "orange" :weight light))))
 '(isearch ((((type tty pc) (class color)) (:background "red" :foreground "yellow"))))
 '(lazy-highlight ((((type tty pc) (class color)) (:background "blue"))))
 '(skk-prefix-hiragana-face ((((class color) (type tty)) nil))))

;; Site specific stuff.
(condition-case nil
    (load-library "site.el")
  (error nil))
