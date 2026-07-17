(local ansi (require "vtx.ansi"))

(local progress-m (require "vtx.widget.progress"))

(local faith (require "faith"))

(local bar-opts {:bar-fg ansi.fg.green :empty "░" :fill "█" :width 10})

(fn test-fmt-duration-zero []
  (faith.= "0:00" (progress-m.fmt-duration 0)))

(fn test-fmt-duration-seconds []
  (faith.= "0:09" (progress-m.fmt-duration 9)))

(fn test-fmt-duration-one-minute []
  (faith.= "1:00" (progress-m.fmt-duration 60)))

(fn test-fmt-duration-mixed []
  (faith.= "1:30" (progress-m.fmt-duration 90)))

(fn test-fmt-duration-59s []
  (faith.= "0:59" (progress-m.fmt-duration 59)))

(fn test-fmt-duration-one-hour []
  (faith.= "1:00:00" (progress-m.fmt-duration 3600)))

(fn test-fmt-duration-hms []
  (faith.= "1:01:01" (progress-m.fmt-duration 3661)))

(fn test-fmt-duration-truncates []
  (faith.= "0:03" (progress-m.fmt-duration 3.9)))

(fn test-fmt-rate-plain []
  (faith.= "1.0/s" (progress-m.fmt-rate 1 nil)))

(fn test-fmt-rate-plain-large []
  (faith.= "1000.0/s" (progress-m.fmt-rate 1000 nil)))

(fn test-fmt-rate-bytes-small []
  (faith.= "500 B/s" (progress-m.fmt-rate 500 "B")))

(fn test-fmt-rate-bytes-kb []
  (faith.= "1.5 KB/s" (progress-m.fmt-rate 1500 "B")))

(fn test-fmt-rate-bytes-mb []
  (faith.= "2.0 MB/s" (progress-m.fmt-rate 2000000.0 "B")))

(fn test-fmt-rate-bytes-exact-kb []
  (faith.= "1.0 KB/s" (progress-m.fmt-rate 1000 "B")))

(fn test-rtb-zero-pct []
  (let [state {:done false :title "T" :total 10 :value 0}
        s (ansi.strip (progress-m.render-task-bar state bar-opts))]
    (faith.is (: s "find" "░░░░░░░░░░" 1 true))
    (faith.is (: s "find" "  0%" 1 true))))

(fn test-rtb-full []
  (let [state {:done false :title "T" :total 10 :value 10}
        s (ansi.strip (progress-m.render-task-bar state bar-opts))]
    (faith.is (: s "find" "██████████" 1 true))
    (faith.is (: s "find" "100%" 1 true))))

(fn test-rtb-half []
  (let [state {:done false :title "T" :total 10 :value 5}
        s (ansi.strip (progress-m.render-task-bar state bar-opts))]
    (faith.is (: s "find" "█████░░░░░" 1 true))
    (faith.is (: s "find" " 50%" 1 true))))

(fn test-rtb-title []
  (let [state {:done false :title "Compiling" :total 1 :value 0}
        s (ansi.strip (progress-m.render-task-bar state bar-opts))]
    (faith.is (: s "find" "Compiling" 1 true))))

(fn test-rtb-done-mark []
  (let [state {:done true :title "Done" :total 1 :value 1}
        s (ansi.strip (progress-m.render-task-bar state bar-opts))]
    (faith.is (: s "find" "✓" 1 true))))

(fn test-rtb-not-done-no-mark []
  (let [state {:done false :title "T" :total 1 :value 0}
        s (ansi.strip (progress-m.render-task-bar state bar-opts))]
    (faith.= nil (: s "find" "✓" 1 true))))

(fn test-rtb-zero-total []
  (let [state {:done false :title "T" :total 0 :value 0}
        s (ansi.strip (progress-m.render-task-bar state bar-opts))]
    (faith.is (: s "find" "  0%" 1 true))))

(fn test-rtb-caps-at-100 []
  (let [state {:done false :title "T" :total 5 :value 10}
        s (ansi.strip (progress-m.render-task-bar state bar-opts))]
    (faith.is (: s "find" "100%" 1 true))))

{:test-fmt-duration-59s test-fmt-duration-59s
 :test-fmt-duration-hms test-fmt-duration-hms
 :test-fmt-duration-mixed test-fmt-duration-mixed
 :test-fmt-duration-one-hour test-fmt-duration-one-hour
 :test-fmt-duration-one-minute test-fmt-duration-one-minute
 :test-fmt-duration-seconds test-fmt-duration-seconds
 :test-fmt-duration-truncates test-fmt-duration-truncates
 :test-fmt-duration-zero test-fmt-duration-zero
 :test-fmt-rate-bytes-exact-kb test-fmt-rate-bytes-exact-kb
 :test-fmt-rate-bytes-kb test-fmt-rate-bytes-kb
 :test-fmt-rate-bytes-mb test-fmt-rate-bytes-mb
 :test-fmt-rate-bytes-small test-fmt-rate-bytes-small
 :test-fmt-rate-plain test-fmt-rate-plain
 :test-fmt-rate-plain-large test-fmt-rate-plain-large
 :test-rtb-caps-at-100 test-rtb-caps-at-100
 :test-rtb-done-mark test-rtb-done-mark
 :test-rtb-full test-rtb-full
 :test-rtb-half test-rtb-half
 :test-rtb-not-done-no-mark test-rtb-not-done-no-mark
 :test-rtb-title test-rtb-title
 :test-rtb-zero-pct test-rtb-zero-pct
 :test-rtb-zero-total test-rtb-zero-total}
