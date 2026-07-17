(local ansi (require "vtx.ansi"))

(local sparkline-m (require "vtx.widget.sparkline"))

(local faith (require "faith"))

(fn test-sparkline-empty []
  (faith.= "" (sparkline-m.sparkline [])))

(fn test-sparkline-nil []
  (faith.= "" (sparkline-m.sparkline nil)))

(fn test-sparkline-single []
  (let [s (ansi.strip (sparkline-m.sparkline [5]))]
    (faith.= 1 (ansi.len s))))

(fn test-sparkline-count []
  (let [s (ansi.strip (sparkline-m.sparkline [1 2 3 4 5]))]
    (faith.= 5 (ansi.len s))))

(fn test-sparkline-uniform-uses-mid []
  (let [s (ansi.strip (sparkline-m.sparkline [3 3 3 3]))]
    (faith.= 4 (ansi.len s))
    (faith.is (: s "find" (. sparkline-m.bar-chars 4) 1 true))))

(fn test-sparkline-max-char []
  (let [s (ansi.strip (sparkline-m.sparkline [0 100]))]
    (faith.is (: s "find" "█" 1 true))))

(fn test-sparkline-min-char []
  (let [s (ansi.strip (sparkline-m.sparkline [0 100]))]
    (faith.is (: s "find" "▁" 1 true))))

(fn test-sparkline-label []
  (let [s (ansi.strip (sparkline-m.sparkline [1 2 3] {:label "Load"}))]
    (faith.is (: s "find" "Load" 1 true))))

(fn test-sparkline-has-ansi []
  (let [s (sparkline-m.sparkline [1 2 3])]
    (faith.is (: s "find" "\027"))))

(fn test-sparkline-bar-chars-count []
  (faith.= 8 (# sparkline-m.bar-chars)))

{:test-sparkline-bar-chars-count test-sparkline-bar-chars-count
 :test-sparkline-count test-sparkline-count
 :test-sparkline-empty test-sparkline-empty
 :test-sparkline-has-ansi test-sparkline-has-ansi
 :test-sparkline-label test-sparkline-label
 :test-sparkline-max-char test-sparkline-max-char
 :test-sparkline-min-char test-sparkline-min-char
 :test-sparkline-nil test-sparkline-nil
 :test-sparkline-single test-sparkline-single
 :test-sparkline-uniform-uses-mid test-sparkline-uniform-uses-mid}
