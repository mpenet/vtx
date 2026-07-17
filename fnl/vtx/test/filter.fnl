(local filter-m (require "vtx.widget.filter"))
(local faith (require "faith"))

;;; fuzzy-match

(fn test-fuzzy-empty-query [] (faith.= 0 (# (filter-m.fuzzy-match "hello" ""))))
(fn test-fuzzy-no-match [] (faith.= nil (filter-m.fuzzy-match "hello" "xyz")))
(fn test-fuzzy-no-match-2 [] (faith.= nil (filter-m.fuzzy-match "abc" "d")))
(fn test-fuzzy-query-longer [] (faith.= nil (filter-m.fuzzy-match "hi" "hello")))
(fn test-fuzzy-single-char []
  (let [r (filter-m.fuzzy-match "hello" "h")]
    (faith.is r)
    (faith.= 1 (# r))
    (faith.= 1 (. r 1))))
(fn test-fuzzy-single-char-mid []
  (let [r (filter-m.fuzzy-match "hello" "e")]
    (faith.is r)
    (faith.= 2 (. r 1))))
(fn test-fuzzy-hl-in-hello []
  (let [r (filter-m.fuzzy-match "hello" "hl")]
    (faith.is r)
    (faith.= 1 (. r 1))
    (faith.= 3 (. r 2))))
(fn test-fuzzy-exact []
  (let [r (filter-m.fuzzy-match "hello" "hello")]
    (faith.is r)
    (faith.= 5 (# r))))
(fn test-fuzzy-case-insensitive []
  (faith.is (filter-m.fuzzy-match "Hello" "hl")))
(fn test-fuzzy-allcaps []
  (faith.is (filter-m.fuzzy-match "HELLO" "hl")))
(fn test-fuzzy-non-consecutive []
  (let [r (filter-m.fuzzy-match "abcdef" "ace")]
    (faith.is r)
    (faith.= 1 (. r 1))
    (faith.= 3 (. r 2))
    (faith.= 5 (. r 3))))
(fn test-fuzzy-first-occurrence-greedy []
  ;; query "a" in "abab": first a is at pos 1
  (let [r (filter-m.fuzzy-match "abab" "a")]
    (faith.= 1 (. r 1))))
(fn test-fuzzy-positions-count []
  (let [r (filter-m.fuzzy-match "abcde" "bde")]
    (faith.= 3 (# r))
    (faith.= 2 (. r 1))
    (faith.= 4 (. r 2))
    (faith.= 5 (. r 3))))

;;; filter-items

(fn test-items-empty-query []
  (let [r (filter-m.filter-items ["hello" "world" "help"] "" true)]
    (faith.= 3 (# r))
    (faith.= 1 (. (. r 1) :i))
    (faith.= 0 (# (. (. r 1) :positions)))))
(fn test-items-empty-list-fuzzy []
  (faith.= 0 (# (filter-m.filter-items [] "hel" true))))
(fn test-items-empty-list-exact []
  (faith.= 0 (# (filter-m.filter-items [] "hel" false))))
(fn test-items-empty-list-empty-q []
  (faith.= 0 (# (filter-m.filter-items [] "" true))))
(fn test-items-fuzzy-hel []
  (faith.= 2 (# (filter-m.filter-items ["hello" "world" "help"] "hel" true))))
(fn test-items-fuzzy-world []
  (let [r (filter-m.filter-items ["hello" "world" "help"] "world" true)]
    (faith.= 1 (# r))
    (faith.= "world" (. (. r 1) :item))))
(fn test-items-substring []
  (let [r (filter-m.filter-items ["hello" "world"] "world" false)]
    (faith.= 1 (# r))
    (faith.= "world" (. (. r 1) :item))))
(fn test-items-substring-positions []
  ;; substring mode: positions cover the contiguous match span
  (let [r (filter-m.filter-items ["hello"] "ell" false)]
    (faith.= 1 (# r))
    (let [pos (. (. r 1) :positions)]
      (faith.= 2 (. pos 1))
      (faith.= 3 (. pos 2))
      (faith.= 4 (. pos 3)))))
(fn test-items-no-fuzzy []
  (faith.= 0 (# (filter-m.filter-items ["hello" "world"] "xyz" true))))
(fn test-items-no-substring []
  (faith.= 0 (# (filter-m.filter-items ["hello" "world"] "xyz" false))))
(fn test-items-case-fuzzy []
  (faith.= 1 (# (filter-m.filter-items ["Hello" "World"] "hel" true))))
(fn test-items-case-substring []
  (faith.= 1 (# (filter-m.filter-items ["Hello" "World"] "hel" false))))
(fn test-items-orig-index []
  (let [r (filter-m.filter-items ["aa" "bb" "cc"] "cc" true)]
    (faith.= 3 (. (. r 1) :i))))
(fn test-items-orig-index-preserved-order []
  ;; items returned in original order when all match
  (let [r (filter-m.filter-items ["a" "b" "c"] "" true)]
    (faith.= 1 (. (. r 1) :i))
    (faith.= 2 (. (. r 2) :i))
    (faith.= 3 (. (. r 3) :i))))
(fn test-items-single-item-match []
  (faith.= 1 (# (filter-m.filter-items ["only"] "only" true))))
(fn test-items-single-item-no-match []
  (faith.= 0 (# (filter-m.filter-items ["only"] "nope" true))))

{:test-fuzzy-empty-query test-fuzzy-empty-query
 :test-fuzzy-no-match test-fuzzy-no-match
 :test-fuzzy-no-match-2 test-fuzzy-no-match-2
 :test-fuzzy-query-longer test-fuzzy-query-longer
 :test-fuzzy-single-char test-fuzzy-single-char
 :test-fuzzy-single-char-mid test-fuzzy-single-char-mid
 :test-fuzzy-hl-in-hello test-fuzzy-hl-in-hello
 :test-fuzzy-exact test-fuzzy-exact
 :test-fuzzy-case-insensitive test-fuzzy-case-insensitive
 :test-fuzzy-allcaps test-fuzzy-allcaps
 :test-fuzzy-non-consecutive test-fuzzy-non-consecutive
 :test-fuzzy-first-occurrence-greedy test-fuzzy-first-occurrence-greedy
 :test-fuzzy-positions-count test-fuzzy-positions-count
 :test-items-empty-query test-items-empty-query
 :test-items-empty-list-fuzzy test-items-empty-list-fuzzy
 :test-items-empty-list-exact test-items-empty-list-exact
 :test-items-empty-list-empty-q test-items-empty-list-empty-q
 :test-items-fuzzy-hel test-items-fuzzy-hel
 :test-items-fuzzy-world test-items-fuzzy-world
 :test-items-substring test-items-substring
 :test-items-substring-positions test-items-substring-positions
 :test-items-no-fuzzy test-items-no-fuzzy
 :test-items-no-substring test-items-no-substring
 :test-items-case-fuzzy test-items-case-fuzzy
 :test-items-case-substring test-items-case-substring
 :test-items-orig-index test-items-orig-index
 :test-items-orig-index-preserved-order test-items-orig-index-preserved-order
 :test-items-single-item-match test-items-single-item-match
 :test-items-single-item-no-match test-items-single-item-no-match}
