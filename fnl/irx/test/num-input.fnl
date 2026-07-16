(local num-m (require "irx.widget.num-input"))

(local faith (require "faith"))

;;; fmt

(fn test-fmt-zero []
  (faith.= "0" (num-m.fmt 0 0)))

(fn test-fmt-integer []
  (faith.= "42" (num-m.fmt 42 0)))

(fn test-fmt-negative []
  (faith.= "-5" (num-m.fmt -5 0)))

(fn test-fmt-floors []
  (faith.= "3" (num-m.fmt 3.9 0)))

(fn test-fmt-one-decimal []
  (faith.= "1.5" (num-m.fmt 1.5 1)))

(fn test-fmt-two-decimals []
  (faith.= "3.14" (num-m.fmt 3.14 2)))

(fn test-fmt-zero-decimal []
  (faith.= "0.00" (num-m.fmt 0 2)))

(fn test-fmt-pads-decimals []
  (faith.= "1.00" (num-m.fmt 1 2)))

;;; valid?

(fn test-valid-no-bounds []
  (faith.is (num-m.valid? 42 {})))

(fn test-valid-nil-n []
  (faith.= nil (num-m.valid? nil {})))

(fn test-valid-min-ok []
  (faith.is (num-m.valid? 5 {:min 0})))

(fn test-valid-min-exact []
  (faith.is (num-m.valid? 0 {:min 0})))

(fn test-valid-below-min []
  (faith.= nil (num-m.valid? -1 {:min 0})))

(fn test-valid-max-ok []
  (faith.is (num-m.valid? 5 {:max 10})))

(fn test-valid-max-exact []
  (faith.is (num-m.valid? 10 {:max 10})))

(fn test-valid-above-max []
  (faith.= nil (num-m.valid? 11 {:max 10})))

(fn test-valid-in-range []
  (faith.is (num-m.valid? 5 {:max 10 :min 0})))

(fn test-valid-at-min-of-range []
  (faith.is (num-m.valid? 0 {:max 10 :min 0})))

(fn test-valid-at-max-of-range []
  (faith.is (num-m.valid? 10 {:max 10 :min 0})))

(fn test-valid-below-range []
  (faith.= nil (num-m.valid? -1 {:max 10 :min 0})))

(fn test-valid-above-range []
  (faith.= nil (num-m.valid? 11 {:max 10 :min 0})))

{:test-fmt-floors test-fmt-floors
 :test-fmt-integer test-fmt-integer
 :test-fmt-negative test-fmt-negative
 :test-fmt-one-decimal test-fmt-one-decimal
 :test-fmt-pads-decimals test-fmt-pads-decimals
 :test-fmt-two-decimals test-fmt-two-decimals
 :test-fmt-zero test-fmt-zero
 :test-fmt-zero-decimal test-fmt-zero-decimal
 :test-valid-above-max test-valid-above-max
 :test-valid-above-range test-valid-above-range
 :test-valid-at-max-of-range test-valid-at-max-of-range
 :test-valid-at-min-of-range test-valid-at-min-of-range
 :test-valid-below-min test-valid-below-min
 :test-valid-below-range test-valid-below-range
 :test-valid-in-range test-valid-in-range
 :test-valid-max-exact test-valid-max-exact
 :test-valid-max-ok test-valid-max-ok
 :test-valid-min-exact test-valid-min-exact
 :test-valid-min-ok test-valid-min-ok
 :test-valid-nil-n test-valid-nil-n
 :test-valid-no-bounds test-valid-no-bounds}
