(local ansi (require "vtx.ansi"))

(local choose-m (require "vtx.widget.choose"))

(local faith (require "faith"))

;;; search-items

(fn test-si-empty-query []
  (faith.= 0 (# (choose-m.search-items ["a" "b"] ""))))

(fn test-si-no-match []
  (faith.= 0 (# (choose-m.search-items ["foo" "bar"] "xyz"))))

(fn test-si-single-match []
  (let [r (choose-m.search-items ["foo" "bar" "baz"] "foo")]
    (faith.= 1 (# r))
    (faith.= 1 (. r 1))))

(fn test-si-multiple-matches []
  (let [r (choose-m.search-items ["foo" "bar" "baz"] "ba")]
    (faith.= 2 (# r))
    (faith.= 2 (. r 1))
    (faith.= 3 (. r 2))))

(fn test-si-case-insensitive []
  (let [r (choose-m.search-items ["Foo" "Bar"] "foo")]
    (faith.= 1 (# r))
    (faith.= 1 (. r 1))))

(fn test-si-substring []
  (let [r (choose-m.search-items ["foobar" "foobaz"] "bar")]
    (faith.= 1 (# r))
    (faith.= 1 (. r 1))))

(fn test-si-all-match []
  (let [r (choose-m.search-items ["a" "a" "a"] "a")]
    (faith.= 3 (# r))))

(fn test-si-returns-indices []
  (let [r (choose-m.search-items ["x" "match" "y" "match2"] "match")]
    (faith.= 2 (# r))
    (faith.= 2 (. r 1))
    (faith.= 4 (. r 2))))

(fn test-si-empty-list []
  (faith.= 0 (# (choose-m.search-items [] "foo"))))

;;; highlight-match

(fn test-hm-empty-query []
  (faith.= "hello" (choose-m.highlight-match "hello" "")))

(fn test-hm-no-match []
  (faith.= "hello" (choose-m.highlight-match "hello" "xyz")))

(fn test-hm-match-has-escape []
  (let [s (choose-m.highlight-match "hello" "ell")]
    (faith.is (: s "find" "\027"))))

(fn test-hm-content-preserved []
  (faith.= "hello" (ansi.strip (choose-m.highlight-match "hello" "ell"))))

(fn test-hm-match-at-start []
  (faith.= "hello" (ansi.strip (choose-m.highlight-match "hello" "he"))))

(fn test-hm-match-at-end []
  (faith.= "hello" (ansi.strip (choose-m.highlight-match "hello" "lo"))))

(fn test-hm-case-insensitive []
  (let [s (choose-m.highlight-match "Hello" "hello")]
    (faith.is (: s "find" "\027"))
    (faith.= "Hello" (ansi.strip s))))

(fn test-hm-no-match-returns-original []
  (let [item "nothing"]
    (faith.= item (choose-m.highlight-match item "zzz"))))

(fn test-hm-full-match []
  (faith.= "hi" (ansi.strip (choose-m.highlight-match "hi" "hi"))))

{:test-hm-case-insensitive test-hm-case-insensitive
 :test-hm-content-preserved test-hm-content-preserved
 :test-hm-empty-query test-hm-empty-query
 :test-hm-full-match test-hm-full-match
 :test-hm-match-at-end test-hm-match-at-end
 :test-hm-match-at-start test-hm-match-at-start
 :test-hm-match-has-escape test-hm-match-has-escape
 :test-hm-no-match test-hm-no-match
 :test-hm-no-match-returns-original test-hm-no-match-returns-original
 :test-si-all-match test-si-all-match
 :test-si-case-insensitive test-si-case-insensitive
 :test-si-empty-list test-si-empty-list
 :test-si-empty-query test-si-empty-query
 :test-si-multiple-matches test-si-multiple-matches
 :test-si-no-match test-si-no-match
 :test-si-returns-indices test-si-returns-indices
 :test-si-single-match test-si-single-match
 :test-si-substring test-si-substring}
