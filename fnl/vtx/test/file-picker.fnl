(local fp-m (require "vtx.widget.file-picker"))

(local faith (require "faith"))

(fn test-parent-deep []
  (faith.= "/home/user/code" (fp-m.parent-path "/home/user/code/vtx")))

(fn test-parent-single-level []
  (faith.= "/" (fp-m.parent-path "/foo")))

(fn test-parent-root []
  (faith.= "/" (fp-m.parent-path "/")))

(fn test-parent-relative []
  (faith.= "." (fp-m.parent-path "./subdir")))

(fn test-parent-two-level []
  (faith.= "/a" (fp-m.parent-path "/a/b")))

(fn test-resolve-normal []
  (faith.= "/home/user/file.txt" (fp-m.resolve-path "/home/user" "file.txt")))

(fn test-resolve-root []
  (faith.= "/file.txt" (fp-m.resolve-path "/" "file.txt")))

(fn test-resolve-relative []
  (faith.= "./subdir/file.fnl" (fp-m.resolve-path "./subdir" "file.fnl")))

(fn test-shell-quote-basic []
  (faith.= "'hello'" (fp-m.shell-quote "hello")))

(fn test-shell-quote-with-space []
  (faith.= "'hello world'" (fp-m.shell-quote "hello world")))

(fn test-shell-quote-with-single-quote []
  (faith.= "'it'\\''s'" (fp-m.shell-quote "it's")))

(fn test-shell-quote-empty []
  (faith.= "''" (fp-m.shell-quote "")))

{:test-parent-deep test-parent-deep
 :test-parent-relative test-parent-relative
 :test-parent-root test-parent-root
 :test-parent-single-level test-parent-single-level
 :test-parent-two-level test-parent-two-level
 :test-resolve-normal test-resolve-normal
 :test-resolve-relative test-resolve-relative
 :test-resolve-root test-resolve-root
 :test-shell-quote-basic test-shell-quote-basic
 :test-shell-quote-empty test-shell-quote-empty
 :test-shell-quote-with-single-quote test-shell-quote-with-single-quote
 :test-shell-quote-with-space test-shell-quote-with-space}
