(local ansi (require "tiki.ansi"))

(local dialog-m (require "tiki.widget.dialog"))

(local faith (require "faith"))

(fn make-opts []
  {:active-fg ansi.fg.cyan :button-sep "  " :fg ansi.fg.white})

(fn test-render-buttons-contains-labels []
  (let [s (ansi.strip (dialog-m.render-buttons ["OK" "Cancel"] 1 (make-opts)))]
    (faith.is (: s "find" "OK" 1 true))
    (faith.is (: s "find" "Cancel" 1 true))))

(fn test-render-buttons-has-ansi []
  (let [s (dialog-m.render-buttons ["OK" "Cancel"] 1 (make-opts))]
    (faith.is (: s "find" "\027"))))

(fn test-render-buttons-single []
  (let [s (ansi.strip (dialog-m.render-buttons ["OK"] 1 (make-opts)))]
    (faith.is (: s "find" "OK" 1 true))))

(fn test-render-buttons-three []
  (let [s (ansi.strip (dialog-m.render-buttons ["A" "B" "C"] 2 (make-opts)))]
    (faith.is (: s "find" "A" 1 true))
    (faith.is (: s "find" "B" 1 true))
    (faith.is (: s "find" "C" 1 true))))

(fn test-render-buttons-active-second []
  (let [s1 (dialog-m.render-buttons ["X" "Y"] 1 (make-opts))
        s2 (dialog-m.render-buttons ["X" "Y"] 2 (make-opts))]
    (faith.is (not= s1 s2))))

{:test-render-buttons-active-second test-render-buttons-active-second
 :test-render-buttons-contains-labels test-render-buttons-contains-labels
 :test-render-buttons-has-ansi test-render-buttons-has-ansi
 :test-render-buttons-single test-render-buttons-single
 :test-render-buttons-three test-render-buttons-three}
