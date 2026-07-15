(local ansi (require "tiki.ansi"))
(local pager-m (require "tiki.widget.pager"))
(local faith (require "faith"))

;;; highlight-search

(fn test-highlight-empty-query []
  (faith.= "hello world" (pager-m.highlight-search "hello world" "")))
(fn test-highlight-no-match []
  (faith.= "hello" (pager-m.highlight-search "hello" "xyz")))
(fn test-highlight-no-match-stripped []
  (faith.= "hello" (ansi.strip (pager-m.highlight-search "hello" "xyz"))))
(fn test-highlight-match-has-esc []
  (let [s (pager-m.highlight-search "hello world" "ell")]
    (faith.is (: s :find "\027"))))
(fn test-highlight-match-stripped []
  (faith.= "hello world" (ansi.strip (pager-m.highlight-search "hello world" "ell"))))
(fn test-highlight-at-start []
  (let [s (pager-m.highlight-search "hello" "he")]
    (faith.is (: s :find "\027"))
    (faith.= "hello" (ansi.strip s))))
(fn test-highlight-at-end []
  (let [s (pager-m.highlight-search "hello world" "world")]
    (faith.is (: s :find "\027"))
    (faith.= "hello world" (ansi.strip s))))
(fn test-highlight-full-line []
  (faith.= "test" (ansi.strip (pager-m.highlight-search "test" "test"))))
(fn test-highlight-case-insensitive []
  (let [s (pager-m.highlight-search "Hello World" "hello")]
    (faith.is (: s :find "\027"))
    (faith.= "Hello World" (ansi.strip s))))
(fn test-highlight-multi-occurrence []
  ;; "b" appears twice in "abcabc"; both occurrences highlighted
  (let [s (pager-m.highlight-search "abcabc" "b")]
    ;; stripped content unchanged
    (faith.= "abcabc" (ansi.strip s))
    ;; more than one escape present (two highlight regions)
    (let [count (select 2 (: s :gsub "\027%[" ""))]
      (faith.is (> count 2)))))
(fn test-highlight-single-char-query []
  (let [s (pager-m.highlight-search "aaa" "a")]
    (faith.= "aaa" (ansi.strip s))))
(fn test-highlight-preserves-surrounding []
  ;; text before and after match is unchanged
  (let [s (pager-m.highlight-search "prefix MATCH suffix" "match")]
    (faith.is (: s :find "prefix" 1 true))
    (faith.is (: s :find "suffix" 1 true))))

;;; find-matches

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

{:test-highlight-empty-query test-highlight-empty-query
 :test-highlight-no-match test-highlight-no-match
 :test-highlight-no-match-stripped test-highlight-no-match-stripped
 :test-highlight-match-has-esc test-highlight-match-has-esc
 :test-highlight-match-stripped test-highlight-match-stripped
 :test-highlight-at-start test-highlight-at-start
 :test-highlight-at-end test-highlight-at-end
 :test-highlight-full-line test-highlight-full-line
 :test-highlight-case-insensitive test-highlight-case-insensitive
 :test-highlight-multi-occurrence test-highlight-multi-occurrence
 :test-highlight-single-char-query test-highlight-single-char-query
 :test-highlight-preserves-surrounding test-highlight-preserves-surrounding
 :test-find-empty-query test-find-empty-query
 :test-find-empty-lines test-find-empty-lines
 :test-find-count test-find-count
 :test-find-no-matches test-find-no-matches
 :test-find-case-insensitive test-find-case-insensitive
 :test-find-multiple test-find-multiple
 :test-find-single-line-match test-find-single-line-match
 :test-find-match-in-middle test-find-match-in-middle
 :test-find-all-lines-match test-find-all-lines-match
 :test-find-first-line test-find-first-line
 :test-find-last-line test-find-last-line}
