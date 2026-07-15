(local ansi (require "tiki.ansi"))

(local gauge-m (require "tiki.widget.gauge"))

(local faith (require "faith"))

(fn test-gauge-empty []
  (let [g (gauge-m.gauge 0)]
    (faith.is (: g "find" "░" 1 true))
    (faith.is (: g "find" "  0%" 1 true))))

(fn test-gauge-full []
  (let [g (gauge-m.gauge 1)]
    (faith.is (: g "find" "█" 1 true))
    (faith.is (: g "find" "100%" 1 true))))

(fn test-gauge-half []
  (let [g (gauge-m.gauge 0.5)]
    (faith.is (: g "find" " 50%" 1 true))))

(fn test-gauge-with-total []
  (let [g (gauge-m.gauge 5 10)]
    (faith.is (: g "find" " 50%" 1 true))))

(fn test-gauge-label []
  (let [g (gauge-m.gauge 0.5 nil {:label "CPU"})]
    (faith.is (: g "find" "CPU" 1 true))))

(fn test-gauge-no-pct []
  (let [g (gauge-m.gauge 0.5 nil {:show-pct false})]
    (faith.= nil (g:find "%%"))))

(fn test-gauge-width []
  (let [g (ansi.strip (gauge-m.gauge 0 nil {:show-pct false :width 10}))]
    (faith.= 12 (ansi.len g))))

(fn test-gauge-clamps-over-1 []
  (let [g (gauge-m.gauge 2.0)]
    (faith.is (: g "find" "100%" 1 true))))

(fn test-gauge-clamps-below-0 []
  (let [g (gauge-m.gauge -0.5)]
    (faith.is (: g "find" "  0%" 1 true))))

(fn test-gauge-total-zero []
  (let [g (gauge-m.gauge 5 0)]
    (faith.is (: g "find" "  0%" 1 true))))

(fn test-gauge-has-brackets []
  (let [g (ansi.strip (gauge-m.gauge 0.5 nil {:show-pct false :width 4}))]
    (faith.is (: g "find" "%[" 1))
    (faith.is (: g "find" "%]" 1))))

{:test-gauge-clamps-below-0 test-gauge-clamps-below-0
 :test-gauge-clamps-over-1 test-gauge-clamps-over-1
 :test-gauge-empty test-gauge-empty
 :test-gauge-full test-gauge-full
 :test-gauge-half test-gauge-half
 :test-gauge-has-brackets test-gauge-has-brackets
 :test-gauge-label test-gauge-label
 :test-gauge-no-pct test-gauge-no-pct
 :test-gauge-total-zero test-gauge-total-zero
 :test-gauge-width test-gauge-width
 :test-gauge-with-total test-gauge-with-total}
