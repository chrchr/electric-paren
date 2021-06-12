electric-paren
----

`electric-paren` is an Emacs mode for interactive Lisp modes to
enable execution of commands when the expression is complete. Typing
a closing parenthesis on a Lisp expression invokes the command,
without requiring the <return> key. This functionality is copied from the
Symbolics Genera operating system. It currently works in `ielm`,
`eshell`, `sly`, `slime`, and `inferior-lisp-mode`.


Installation
----

Add something like this to your Emacs startup file:

```
(use-package electric-paren
  :commands (electric-paren-enable)
  :hook
  (after-init . electric-paren-enable))
```
