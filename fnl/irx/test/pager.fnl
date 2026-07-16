(local ansi (require "irx.ansi"))

(local pager-m (require "irx.widget.pager"))

(local faith (require "faith"))

(fn test-wrap-line-short []
  (faith.= ["hello"] (pager-m.wrap-line "hello" 10)))

(fn test-wrap-line-empty []
  (faith.= [""] (pager-m.wrap-line "" 5)))

(fn test-wrap-line-exact []
  (faith.= ["hello"] (pager-m.wrap-line "hello" 5)))

(fn test-wrap-line-overflow []
  (let [r (pager-m.wrap-line "hello world" 5)]
    (faith.= 3 (# r))
    (faith.= "hello" (. r 1))
    (faith.= " worl" (. r 2))
    (faith.= "d" (. r 3))))

(fn test-wrap-line-three-chunks []
  (let [r (pager-m.wrap-line "abcdefghij" 3)]
    (faith.= 4 (# r))
    (faith.= "abc" (. r 1))
    (faith.= "def" (. r 2))
    (faith.= "ghi" (. r 3))
    (faith.= "j" (. r 4))))

(fn test-wrap-line-ansi-passthrough []
  (let [s (ansi.style "hello world" ansi.bold)
        r (pager-m.wrap-line s 5)]
    (faith.= 3 (# r))
    (faith.= "hello" (ansi.strip (. r 1)))
    (faith.= " worl" (ansi.strip (. r 2)))
    (faith.= "d" (ansi.strip (. r 3)))))

(fn test-wrap-line-maxw-zero []
  (faith.= ["hi"] (pager-m.wrap-line "hi" 0)))

(fn test-reflow-single-short []
  (let [r (pager-m.reflow-lines ["hello"] 20)]
    (faith.= 1 (# r))
    (faith.= "hello" (. r 1))))

(fn test-reflow-single-overflow []
  (let [r (pager-m.reflow-lines ["abcde"] 3)]
    (faith.= 2 (# r))
    (faith.= "abc" (. r 1))
    (faith.= "de" (. r 2))))

(fn test-reflow-multi-lines []
  (let [r (pager-m.reflow-lines ["ab" "cde"] 5)]
    (faith.= 2 (# r))
    (faith.= "ab" (. r 1))
    (faith.= "cde" (. r 2))))

(fn test-reflow-expands-count []
  (let [r (pager-m.reflow-lines ["abcdef" "xyz"] 3)]
    (faith.= 3 (# r))
    (faith.= "abc" (. r 1))
    (faith.= "def" (. r 2))
    (faith.= "xyz" (. r 3))))

(fn test-highlight-empty-query []
  (faith.= "hello world" (pager-m.highlight-search "hello world" "")))

(fn test-highlight-no-match []
  (faith.= "hello" (pager-m.highlight-search "hello" "xyz")))

(fn test-highlight-no-match-stripped []
  (faith.= "hello" (ansi.strip (pager-m.highlight-search "hello" "xyz"))))

(fn test-highlight-match-has-esc []
  (let [s (pager-m.highlight-search "hello world" "ell")]
    (faith.is (: s "find" "\027"))))

(fn test-highlight-match-stripped []
  (faith.= "hello world" (ansi.strip (pager-m.highlight-search "hello world" "ell"))))

(fn test-highlight-at-start []
  (let [s (pager-m.highlight-search "hello" "he")]
    (faith.is (: s "find" "\027"))
    (faith.= "hello" (ansi.strip s))))

(fn test-highlight-at-end []
  (let [s (pager-m.highlight-search "hello world" "world")]
    (faith.is (: s "find" "\027"))
    (faith.= "hello world" (ansi.strip s))))

(fn test-highlight-full-line []
  (faith.= "test" (ansi.strip (pager-m.highlight-search "test" "test"))))

(fn test-highlight-case-insensitive []
  (let [s (pager-m.highlight-search "Hello World" "hello")]
    (faith.is (: s "find" "\027"))
    (faith.= "Hello World" (ansi.strip s))))

(fn test-highlight-multi-occurrence []
  (let [s (pager-m.highlight-search "abcabc" "b")]
    (faith.= "abcabc" (ansi.strip s))
    (let [count (select 2 (: s "gsub" "\027%[" ""))]
      (faith.is (> count 2)))))

(fn test-highlight-single-char-query []
  (let [s (pager-m.highlight-search "aaa" "a")]
    (faith.= "aaa" (ansi.strip s))))

(fn test-highlight-preserves-surrounding []
  (let [s (pager-m.highlight-search "prefix MATCH suffix" "match")]
    (faith.is (: s "find" "prefix" 1 true))
    (faith.is (: s "find" "suffix" 1 true))))

(fn test-find-empty-query []
  (faith.= nil (next (pager-m.find-matches ["a" "b"] ""))))

(fn test-find-empty-lines []
  (faith.= nil (next (pager-m.find-matches [] "x"))))

(fn test-find-count []
  (let [r (pager-m.find-matches ["hello" "world" "help"] "hel")]
    (faith.= 2 (# r))
    (faith.= 1 (. r 1))
    (faith.= 3 (. r 2))))

(fn test-find-no-matches []
  (faith.= 0 (# (pager-m.find-matches ["hello" "world"] "xyz"))))

(fn test-find-case-insensitive []
  (let [r (pager-m.find-matches ["Hello" "world"] "hello")]
    (faith.= 1 (# r))
    (faith.= 1 (. r 1))))

(fn test-find-multiple []
  (let [r (pager-m.find-matches ["a" "b" "a"] "a")]
    (faith.= 2 (# r))
    (faith.= 1 (. r 1))
    (faith.= 3 (. r 2))))

(fn test-find-single-line-match []
  (let [r (pager-m.find-matches ["only match"] "match")]
    (faith.= 1 (# r))
    (faith.= 1 (. r 1))))

(fn test-find-match-in-middle []
  (let [r (pager-m.find-matches ["foo" "bar" "baz" "qux"] "ba")]
    (faith.= 2 (# r))
    (faith.= 2 (. r 1))
    (faith.= 3 (. r 2))))

(fn test-find-all-lines-match []
  (let [r (pager-m.find-matches ["a" "a" "a"] "a")]
    (faith.= 3 (# r))))

(fn test-find-first-line []
  (let [r (pager-m.find-matches ["match" "no"] "match")]
    (faith.= 1 (. r 1))))

(fn test-find-last-line []
  (let [lines ["no" "no" "match"]
        r (pager-m.find-matches lines "match")]
    (faith.= 1 (# r))
    (faith.= 3 (. r 1))))

(fn test-render-status-contains-lines []
  (let [s (ansi.strip (pager-m.render-status 0 10 20 1 [] false false ""))]
    (faith.is (s:find "lines" 1 true))))

(fn test-render-status-shows-pct []
  (let [s (ansi.strip (pager-m.render-status 0 10 10 1 [] false false ""))]
    (faith.is (s:find "100%" 1 true))))

(fn test-render-status-partial-pct []
  (let [s (ansi.strip (pager-m.render-status 0 5 10 1 [] false false ""))]
    (faith.is (s:find "50%" 1 true))))

(fn test-render-status-search-match-info []
  (let [s (ansi.strip (pager-m.render-status 0 10 20 2 [1 5 9] false false ""))]
    (faith.is (s:find "[2/3]" 1 true))))

(fn test-render-status-no-match-info-when-empty []
  (let [s (ansi.strip (pager-m.render-status 0 10 20 1 [] false false ""))]
    (faith.= nil (s:find "[" 1 true))))

(fn test-render-status-wrap-hint []
  (let [s (ansi.strip (pager-m.render-status 0 10 20 1 [] false true ""))]
    (faith.is (s:find "[wrap]" 1 true))))

(fn test-render-status-ln-hint []
  (let [s (ansi.strip (pager-m.render-status 0 10 20 1 [] true false ""))]
    (faith.is (s:find "[ln]" 1 true))))

(fn test-render-status-digit-buf []
  (let [s (ansi.strip (pager-m.render-status 0 10 20 1 [] false false "42"))]
    (faith.is (s:find ":42" 1 true))))

(fn test-render-status-no-digit-hint-when-empty []
  (let [s (ansi.strip (pager-m.render-status 0 10 20 1 [] false false ""))]
    (faith.= nil (s:find " :" 1 true))))

(fn test-render-status-has-ansi []
  (let [s (pager-m.render-status 0 10 20 1 [] false false "")]
    (faith.is (s:find "\027"))))

{:test-find-all-lines-match
 test-find-all-lines-match
 :test-find-case-insensitive
 test-find-case-insensitive
 :test-find-count
 test-find-count
 :test-find-empty-lines
 test-find-empty-lines
 :test-find-empty-query
 test-find-empty-query
 :test-find-first-line
 test-find-first-line
 :test-find-last-line
 test-find-last-line
 :test-find-match-in-middle
 test-find-match-in-middle
 :test-find-multiple
 test-find-multiple
 :test-find-no-matches
 test-find-no-matches
 :test-find-single-line-match
 test-find-single-line-match
 :test-highlight-at-end
 test-highlight-at-end
 :test-highlight-at-start
 test-highlight-at-start
 :test-highlight-case-insensitive
 test-highlight-case-insensitive
 :test-highlight-empty-query
 test-highlight-empty-query
 :test-highlight-full-line
 test-highlight-full-line
 :test-highlight-match-has-esc
 test-highlight-match-has-esc
 :test-highlight-match-stripped
 test-highlight-match-stripped
 :test-highlight-multi-occurrence
 test-highlight-multi-occurrence
 :test-highlight-no-match
 test-highlight-no-match
 :test-highlight-no-match-stripped
 test-highlight-no-match-stripped
 :test-highlight-preserves-surrounding
 test-highlight-preserves-surrounding
 :test-highlight-single-char-query
 test-highlight-single-char-query
 :test-reflow-expands-count
 test-reflow-expands-count
 :test-reflow-multi-lines
 test-reflow-multi-lines
 :test-reflow-single-overflow
 test-reflow-single-overflow
 :test-reflow-single-short
 test-reflow-single-short
 :test-render-status-contains-lines
 test-render-status-contains-lines
 :test-render-status-digit-buf
 test-render-status-digit-buf
 :test-render-status-has-ansi
 test-render-status-has-ansi
 :test-render-status-ln-hint
 test-render-status-ln-hint
 :test-render-status-no-digit-hint-when-empty
 test-render-status-no-digit-hint-when-empty
 :test-render-status-no-match-info-when-empty
 test-render-status-no-match-info-when-empty
 :test-render-status-partial-pct
 test-render-status-partial-pct
 :test-render-status-search-match-info
 test-render-status-search-match-info
 :test-render-status-shows-pct
 test-render-status-shows-pct
 :test-render-status-wrap-hint
 test-render-status-wrap-hint
 :test-wrap-line-ansi-passthrough
 test-wrap-line-ansi-passthrough
 :test-wrap-line-empty
 test-wrap-line-empty
 :test-wrap-line-exact
 test-wrap-line-exact
 :test-wrap-line-maxw-zero
 test-wrap-line-maxw-zero
 :test-wrap-line-overflow
 test-wrap-line-overflow
 :test-wrap-line-short
 test-wrap-line-short
 :test-wrap-line-three-chunks
 test-wrap-line-three-chunks}
