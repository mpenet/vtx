(local input-m (require "irx.widget.input"))

(local faith (require "faith"))

(fn test-utf8-start-ascii []
  (faith.= 1 (input-m.utf8-codepoint-start "a" 1)))

(fn test-utf8-start-2byte-first []
  (faith.= 1 (input-m.utf8-codepoint-start "é" 1)))

(fn test-utf8-start-2byte-continuation []
  (faith.= 1 (input-m.utf8-codepoint-start "é" 2)))

(fn test-utf8-start-3byte-continuation []
  (faith.= 1 (input-m.utf8-codepoint-start "─" 3)))

(fn test-utf8-start-after-ascii []
  (faith.= 2 (input-m.utf8-codepoint-start (.. "a" "é") 3)))

(fn test-utf8-start-ascii-before-multibyte []
  (faith.= 1 (input-m.utf8-codepoint-start (.. "a" "é") 1)))

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

(fn test-next-ascii []
  (faith.= 1 (input-m.utf8-next-pos "hello" 0)))

(fn test-next-ascii-mid []
  (faith.= 2 (input-m.utf8-next-pos "hello" 1)))

(fn test-next-at-end []
  (faith.= 5 (input-m.utf8-next-pos "hello" 5)))

(fn test-next-2byte []
  (faith.= 2 (input-m.utf8-next-pos "é" 0)))

(fn test-next-3byte []
  (faith.= 3 (input-m.utf8-next-pos "─" 0)))

(fn test-next-after-ascii-before-2byte []
  (let [s (.. "a" "é")]
    (faith.= 1 (input-m.utf8-next-pos s 0))
    (faith.= 3 (input-m.utf8-next-pos s 1))))

(local base-render-opts {:complete nil
                         :cursor-fg "\027[32m"
                         :placeholder ""
                         :prompt "> "
                         :prompt-fg "\027[36m"
                         :value ""})

(fn test-render-no-ghost []
  (let [s (input-m.render "hello" 5 base-render-opts nil)]
    (faith.is s)))

(fn test-render-with-ghost []
  (let [s (input-m.render "hel" 3 base-render-opts "lo")]
    (faith.is (s:find "lo" 1 true))))

(fn test-render-placeholder-when-empty []
  (let [opts (collect [k v (pairs base-render-opts)] k v)
        _ (tset opts "placeholder" "Type here")
        s (input-m.render "" 0 opts nil)]
    (faith.is (s:find "Type here" 1 true))))

(fn test-render-no-placeholder-when-nonempty []
  (let [opts (collect [k v (pairs base-render-opts)] k v)
        _ (tset opts "placeholder" "Type here")
        s (input-m.render "x" 1 opts nil)]
    (faith.= nil (s:find "Type here" 1 true))))

(fn test-render-contains-prompt []
  (let [s (input-m.render "a" 0 base-render-opts nil)]
    (faith.is (s:find "> " 1 true))))

{:test-cp-all-same-char
 test-cp-all-same-char
 :test-cp-common
 test-cp-common
 :test-cp-empty-candidate
 test-cp-empty-candidate
 :test-cp-first-shorter
 test-cp-first-shorter
 :test-cp-identical
 test-cp-identical
 :test-cp-long-common
 test-cp-long-common
 :test-cp-no-common
 test-cp-no-common
 :test-cp-prefix-is-one
 test-cp-prefix-is-one
 :test-cp-second-shorter
 test-cp-second-shorter
 :test-cp-single
 test-cp-single
 :test-cp-single-char-common
 test-cp-single-char-common
 :test-cp-three-candidates
 test-cp-three-candidates
 :test-next-2byte
 test-next-2byte
 :test-next-3byte
 test-next-3byte
 :test-next-after-ascii-before-2byte
 test-next-after-ascii-before-2byte
 :test-next-ascii
 test-next-ascii
 :test-next-ascii-mid
 test-next-ascii-mid
 :test-next-at-end
 test-next-at-end
 :test-render-contains-prompt
 test-render-contains-prompt
 :test-render-no-ghost
 test-render-no-ghost
 :test-render-no-placeholder-when-nonempty
 test-render-no-placeholder-when-nonempty
 :test-render-placeholder-when-empty
 test-render-placeholder-when-empty
 :test-render-with-ghost
 test-render-with-ghost
 :test-utf8-start-2byte-continuation
 test-utf8-start-2byte-continuation
 :test-utf8-start-2byte-first
 test-utf8-start-2byte-first
 :test-utf8-start-3byte-continuation
 test-utf8-start-3byte-continuation
 :test-utf8-start-after-ascii
 test-utf8-start-after-ascii
 :test-utf8-start-ascii
 test-utf8-start-ascii
 :test-utf8-start-ascii-before-multibyte
 test-utf8-start-ascii-before-multibyte}
