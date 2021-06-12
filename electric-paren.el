;;; electric-paren.el --- Evaluate lisp expressions when they are complete   -*- lexical-binding: t; -*-

;; Copyright (C) 2020-2021 Robert Church

;; Author: Robert Church <chrchr@gmail.com>
;; Created: 2019-02-14
;; Version: 0.1
;; Package-Version: 20210612.0
;; Package-Requires: ((emacs "24.1"))
;; Homepage: https://github.com/chrchr/electric-paren

;;; Commentary:

;; In ielm, eshell, slime repl, and inferior Lisp mode, this package
;; causes instant evaluation of complete expressions when a closing
;; parenthesis is typed.

;;; Code:

(defun electric-paren-complete-sexp-p (min max)
  "Determine whether the text between locations MIN and MAX represent a complete Lisp expression."

  (let ((state
	 (save-excursion
	   (end-of-line)
	   (parse-partial-sexp min max))))
    (and (= (car state) 0) (not (nth 3 state)))))

(defun electric-paren-ielm-paren (arg)
  "Handle close paren keypresses for ielm.  ARG is a character to insert."
  (interactive "P")
  (self-insert-command (prefix-numeric-value arg))
  (when (electric-paren-complete-sexp-p (ielm-pm) (point))
    (ielm-send-input t)))

(defun electric-paren-inferior-lisp-paren (arg)
  "Handle close paren keypresses for inferior-lisp-mode.  ARG is a character to insert."
  (interactive "P")
  (self-insert-command (prefix-numeric-value arg))
  (when (electric-paren-complete-sexp-p
	 (process-mark (get-buffer-process (current-buffer))) (point))
    (comint-send-input)))

(defun electric-paren-eshell-paren (arg)
  "Handle close paren keypresses for eshell.  ARG is a character to insert."
  (interactive "P")
  (self-insert-command (prefix-numeric-value arg))
  (when (electric-paren-complete-sexp-p eshell-last-output-end (point))
    (eshell-send-input)))

(defun electric-paren-eshell-set-keys ()
  "Configure the eshell keymap for electric-parens."
  (define-key eshell-mode-map (kbd ")") #'electric-paren-eshell-paren))

(defun electric-paren-slime-repl-paren (arg)
  "Handle close paren keypresses for slime-repl.  ARG is a character to insert."
  (interactive "P")
  (self-insert-command (prefix-numeric-value arg))
  ;; slime has its own function to determine whether an expression is complete, so use that instead of
  ;; electric-paren-complete-sexp-p.
  (when (slime-input-complete-p slime-repl-input-start-mark (point-max))
    (slime-repl-send-input t)))

(defun electric-paren-sly-mrepl-paren (arg)
  "Handle close paren keypresses for sly-mrepl.  ARG is a character to insert."
  (interactive "P")
  (self-insert-command (prefix-numeric-value arg))
  ;; sly has its own function to determine whether an expression is complete, so use that instead of
  ;; electric-paren-complete-sexp-p.
  (when (sly-input-complete-p (sly-mrepl--mark) (point-max))
    (sly-mrepl-return)))


;;;##autoload
(defun electric-paren-enable ()
  "Enable electric-paren in eshell, slime-repl, inferior-lisp-mode, and ielm."
  (add-hook 'eshell-first-time-mode-hook #'electric-paren-eshell-set-keys)
  (add-hook 'slime-repl-mode-hook
            (lambda ()
              (define-key slime-repl-mode-map (kbd ")")
                #'electric-paren-slime-repl-paren)))
  (add-hook 'sly-mrepl-mode-hook
            (lambda ()
              (define-key sly-mrepl-mode-map (kbd ")")
                #'electric-paren-sly-mrepl-paren)))
  (add-hook 'inferior-lisp-mode-hook
               (lambda ()
                 (define-key inferior-lisp-mode-map (kbd ")")
                   #'electric-paren-inferior-lisp-paren)))
  (add-hook 'ielm-mode-hook
            (lambda ()
              (define-key ielm-map (kbd ")")
                #'electric-paren-ielm-paren))))

(provide 'electric-paren)

;;; electric-paren.el ends here
