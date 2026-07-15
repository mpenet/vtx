(local input-m (require "tiki.widget.input"))

(local faith (require "faith"))

(fn test-cp-single []
  (faith.= "hello" (input-m.common-prefix ["hello"])))

(fn test-cp-identical []
  (faith.= "foo" (input-m.common-prefix ["foo" "foo"])))

(fn test-cp-common []
  (faith.= "fo" (input-m.common-prefix ["foo" "fob"])))

(fn test-cp-no-common []
  (faith.= "" (input-m.common-prefix ["abc" "xyz"])))

(fn test-cp-prefix-is-one []
  (faith.= "a" (input-m.common-prefix ["abc" "axy" "azz"])))

(fn test-cp-first-shorter []
  (faith.= "ab" (input-m.common-prefix ["ab" "abcd"])))

(fn test-cp-second-shorter []
  (faith.= "ab" (input-m.common-prefix ["abcd" "ab"])))

(fn test-cp-empty-candidate []
  (faith.= "" (input-m.common-prefix ["" "abc"])))

(fn test-cp-three-candidates []
  (faith.= "hel" (input-m.common-prefix ["hello" "help" "helm"])))

(fn test-cp-single-char-common []
  (faith.= "f" (input-m.common-prefix ["foo" "far" "fzz"])))

(fn test-cp-all-same-char []
  (faith.= "a" (input-m.common-prefix ["a" "a" "a"])))

(fn test-cp-long-common []
  (faith.= "prefix-" (input-m.common-prefix ["prefix-alpha" "prefix-beta" "prefix-gamma"])))

{:test-cp-all-same-char test-cp-all-same-char
 :test-cp-common test-cp-common
 :test-cp-empty-candidate test-cp-empty-candidate
 :test-cp-first-shorter test-cp-first-shorter
 :test-cp-identical test-cp-identical
 :test-cp-long-common test-cp-long-common
 :test-cp-no-common test-cp-no-common
 :test-cp-prefix-is-one test-cp-prefix-is-one
 :test-cp-second-shorter test-cp-second-shorter
 :test-cp-single test-cp-single
 :test-cp-single-char-common test-cp-single-char-common
 :test-cp-three-candidates test-cp-three-candidates}
