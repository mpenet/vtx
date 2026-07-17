(local ansi (require "vtx.ansi"))

(local util (require "vtx.util"))

(local faith (require "faith"))

(fn test-string-rep-basic []
  (faith.= "ababab" (util.string-rep "ab" 3)))

(fn test-string-rep-single []
  (faith.= "xxxxx" (util.string-rep "x" 5)))

(fn test-string-rep-zero []
  (faith.= "" (util.string-rep "ab" 0)))

(fn test-string-rep-empty []
  (faith.= "" (util.string-rep "" 3)))

(fn test-string-rep-one []
  (faith.= "z" (util.string-rep "z" 1)))

(fn test-string-rep-multi []
  (faith.= "---" (util.string-rep "-" 3)))

(fn test-trunc-short []
  (faith.= "hi" (util.trunc "hi" 10)))

(fn test-trunc-exact []
  (faith.= "hello" (util.trunc "hello" 5)))

(fn test-trunc-empty []
  (faith.= "" (util.trunc "" 5)))

(fn test-trunc-empty-max0 []
  (faith.= "" (util.trunc "" 0)))

(fn test-trunc-ansi-only-passthrough []
  (faith.= ansi.bold (util.trunc ansi.bold 5)))

(fn test-trunc-styled-short []
  (let [s (ansi.style "hi" ansi.bold)]
    (faith.= s (util.trunc s 10))))

(fn test-trunc-width []
  (faith.= 5 (ansi.len (util.trunc "hello world" 5))))

(fn test-trunc-width-8 []
  (faith.= 8 (ansi.len (util.trunc "hello world this is long" 8))))

(fn test-trunc-width-2 []
  (faith.= 2 (ansi.len (util.trunc "hello" 2))))

(fn test-trunc-width-1 []
  (faith.= 1 (ansi.len (util.trunc "hello" 1))))

(fn test-trunc-content-5 []
  (faith.= "hell…" (ansi.strip (util.trunc "hello world" 5))))

(fn test-trunc-content-4 []
  (faith.= "abc…" (ansi.strip (util.trunc "abcde" 4))))

(fn test-trunc-content-2 []
  (faith.= "h…" (ansi.strip (util.trunc "hello" 2))))

(fn test-trunc-ellipsis []
  (faith.is (: (util.trunc "hello world" 5) "find" "…" 1 true)))

(fn test-trunc-ansi-width []
  (faith.= 5 (ansi.len (util.trunc (ansi.style "hello world" ansi.bold) 5))))

(fn test-trunc-ansi-content []
  (faith.= "hell…" (ansi.strip (util.trunc (ansi.style "hello world" ansi.bold) 5))))

(fn test-trunc-ansi-has-esc []
  (let [s (util.trunc (ansi.style "hello world" ansi.bold) 5)]
    (faith.is (: s "find" "\027"))))

(fn test-trunc-long-ansi []
  (let [long (ansi.style "abcdefghijklmnopqrstuvwxyz" ansi.bold ansi.fg.red)]
    (faith.= 10 (ansi.len (util.trunc long 10)))))

(fn test-trunc-utf8-width []
  (faith.= 6 (ansi.len (util.trunc "──────────────" 6))))

(fn test-trunc-utf8-content []
  (faith.= "─────…" (ansi.strip (util.trunc "──────────────" 6))))

(fn test-trunc-utf8-2 []
  (faith.= "─…" (ansi.strip (util.trunc "───" 2))))

(fn test-trunc-utf8-exact []
  (faith.= "──" (util.trunc "──" 2)))

(fn test-trunc-utf8-mixed []
  (faith.= "ab…" (ansi.strip (util.trunc "ab──" 3))))

(fn test-trunc-wide-no-trunc []
  (faith.= "中" (util.trunc "中" 5)))

(fn test-trunc-wide-fit []
  (faith.= "中文" (util.trunc "中文" 4)))

(fn test-trunc-wide-trunc-len []
  (faith.= 4 (ansi.len (util.trunc "中文字" 4))))

(fn test-trunc-wide-boundary-space []
  (faith.= "中 …" (ansi.strip (util.trunc "中文字" 4))))

(fn test-trunc-wide-ascii-then-wide []
  (faith.= "a …" (ansi.strip (util.trunc "a中b" 3))))

(fn test-split-empty-count []
  (faith.= 1 (# (util.split-lines ""))))

(fn test-split-empty-elem []
  (faith.= "" (. (util.split-lines "") 1)))

(fn test-split-single-count []
  (faith.= 1 (# (util.split-lines "hello"))))

(fn test-split-single-content []
  (faith.= "hello" (. (util.split-lines "hello") 1)))

(fn test-split-two-count []
  (faith.= 2 (# (util.split-lines "a
b"))))

(fn test-split-two-first []
  (faith.= "a" (. (util.split-lines "a
b") 1)))

(fn test-split-two-second []
  (faith.= "b" (. (util.split-lines "a
b") 2)))

(fn test-split-three []
  (faith.= 3 (# (util.split-lines "a
b
c"))))

(fn test-split-third []
  (faith.= "c" (. (util.split-lines "a
b
c") 3)))

(fn test-split-trailing-newline []
  (faith.= 2 (# (util.split-lines "a
b
"))))

(fn test-split-trailing-content []
  (faith.= "b" (. (util.split-lines "a
b
") 2)))

(fn test-split-empty-middle []
  (let [r (util.split-lines "a

b")]
    (faith.= 3 (# r))
    (faith.= "" (. r 2))))

(fn test-split-only-newline []
  (faith.= 1 (# (util.split-lines "\n"))))

(fn test-split-spaces []
  (faith.= "line with spaces  " (. (util.split-lines "line with spaces  ") 1)))

(fn test-split-many []
  (let [r (util.split-lines "a
b
c
d
e")]
    (faith.= 5 (# r))
    (faith.= "e" (. r 5))))

(fn test-wrap-short []
  (faith.= "hello" (util.wrap "hello" 10)))

(fn test-wrap-exact []
  (faith.= "hello" (util.wrap "hello" 5)))

(fn test-wrap-basic []
  (faith.= "hello
world" (util.wrap "hello world" 7)))

(fn test-wrap-preserves-newlines []
  (faith.= "a
b" (util.wrap "a
b" 10)))

(fn test-wrap-empty []
  (faith.= "" (util.wrap "" 10)))

(fn test-wrap-single-word-long []
  (faith.= "superlongword" (util.wrap "superlongword" 5)))

(fn test-wrap-three-words []
  (let [s (util.wrap "one two three" 7)
        lines (util.split-lines s)]
    (faith.= 2 (# lines))))

(fn test-wrap-width-zero []
  (faith.= "hello world" (util.wrap "hello world" 0)))

(fn test-wrap-blank-line []
  (let [lines (util.split-lines (util.wrap "a

b" 10))]
    (faith.= 3 (# lines))
    (faith.= "" (. lines 2))))

(fn test-wrap-fits-exactly []
  (faith.= "ab cd" (util.wrap "ab cd" 5)))

{:test-split-empty-count test-split-empty-count
 :test-split-empty-elem test-split-empty-elem
 :test-split-empty-middle test-split-empty-middle
 :test-split-many test-split-many
 :test-split-only-newline test-split-only-newline
 :test-split-single-content test-split-single-content
 :test-split-single-count test-split-single-count
 :test-split-spaces test-split-spaces
 :test-split-third test-split-third
 :test-split-three test-split-three
 :test-split-trailing-content test-split-trailing-content
 :test-split-trailing-newline test-split-trailing-newline
 :test-split-two-count test-split-two-count
 :test-split-two-first test-split-two-first
 :test-split-two-second test-split-two-second
 :test-string-rep-basic test-string-rep-basic
 :test-string-rep-empty test-string-rep-empty
 :test-string-rep-multi test-string-rep-multi
 :test-string-rep-one test-string-rep-one
 :test-string-rep-single test-string-rep-single
 :test-string-rep-zero test-string-rep-zero
 :test-trunc-ansi-content test-trunc-ansi-content
 :test-trunc-ansi-has-esc test-trunc-ansi-has-esc
 :test-trunc-ansi-only-passthrough test-trunc-ansi-only-passthrough
 :test-trunc-ansi-width test-trunc-ansi-width
 :test-trunc-content-2 test-trunc-content-2
 :test-trunc-content-4 test-trunc-content-4
 :test-trunc-content-5 test-trunc-content-5
 :test-trunc-ellipsis test-trunc-ellipsis
 :test-trunc-empty test-trunc-empty
 :test-trunc-empty-max0 test-trunc-empty-max0
 :test-trunc-exact test-trunc-exact
 :test-trunc-long-ansi test-trunc-long-ansi
 :test-trunc-short test-trunc-short
 :test-trunc-styled-short test-trunc-styled-short
 :test-trunc-utf8-2 test-trunc-utf8-2
 :test-trunc-utf8-content test-trunc-utf8-content
 :test-trunc-utf8-exact test-trunc-utf8-exact
 :test-trunc-utf8-mixed test-trunc-utf8-mixed
 :test-trunc-utf8-width test-trunc-utf8-width
 :test-trunc-wide-ascii-then-wide test-trunc-wide-ascii-then-wide
 :test-trunc-wide-boundary-space test-trunc-wide-boundary-space
 :test-trunc-wide-fit test-trunc-wide-fit
 :test-trunc-wide-no-trunc test-trunc-wide-no-trunc
 :test-trunc-wide-trunc-len test-trunc-wide-trunc-len
 :test-trunc-width test-trunc-width
 :test-trunc-width-1 test-trunc-width-1
 :test-trunc-width-2 test-trunc-width-2
 :test-trunc-width-8 test-trunc-width-8
 :test-wrap-basic test-wrap-basic
 :test-wrap-blank-line test-wrap-blank-line
 :test-wrap-empty test-wrap-empty
 :test-wrap-exact test-wrap-exact
 :test-wrap-fits-exactly test-wrap-fits-exactly
 :test-wrap-preserves-newlines test-wrap-preserves-newlines
 :test-wrap-short test-wrap-short
 :test-wrap-single-word-long test-wrap-single-word-long
 :test-wrap-three-words test-wrap-three-words
 :test-wrap-width-zero test-wrap-width-zero}
