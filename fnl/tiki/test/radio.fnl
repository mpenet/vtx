(local ansi (require "tiki.ansi"))

(local radio-m (require "tiki.widget.radio"))

(local faith (require "faith"))

(local opts {:cursor-fg ansi.fg.cyan
             :selected-fg ansi.fg.green
             :unselected-fg ansi.fg.white})

(fn test-unselected-bullet []
  (let [item (radio-m.render-item "opt" 1 2 nil opts)]
    (faith.is (: (ansi.strip item) "find" "○" 1 true))))

(fn test-selected-bullet []
  (let [item (radio-m.render-item "opt" 1 2 1 opts)]
    (faith.is (: (ansi.strip item) "find" "●" 1 true))))

(fn test-cursor-unselected []
  (let [item (radio-m.render-item "opt" 1 1 nil opts)]
    (faith.is (: (ansi.strip item) "find" "○" 1 true))))

(fn test-cursor-and-selected []
  (let [item (radio-m.render-item "opt" 1 1 1 opts)]
    (faith.is (: (ansi.strip item) "find" "●" 1 true))))

(fn test-label-in-output []
  (let [item (radio-m.render-item "hello" 1 1 nil opts)]
    (faith.is (: item "find" "hello" 1 true))))

(fn test-non-cursor-non-selected-has-circle []
  (let [item (radio-m.render-item "opt" 3 1 2 opts)]
    (faith.is (: (ansi.strip item) "find" "○" 1 true))))

(fn test-selected-not-cursor-has-dot []
  (let [item (radio-m.render-item "opt" 2 1 2 opts)]
    (faith.is (: (ansi.strip item) "find" "●" 1 true))))

(fn test-selected-not-cursor-is-not-cursor-color []
  (let [item-sel (radio-m.render-item "x" 2 1 2 opts)
        item-cur (radio-m.render-item "x" 1 1 nil opts)]
    (faith.not= item-sel item-cur)))

{:test-cursor-and-selected test-cursor-and-selected
 :test-cursor-unselected test-cursor-unselected
 :test-label-in-output test-label-in-output
 :test-non-cursor-non-selected-has-circle test-non-cursor-non-selected-has-circle
 :test-selected-bullet test-selected-bullet
 :test-selected-not-cursor-has-dot test-selected-not-cursor-has-dot
 :test-selected-not-cursor-is-not-cursor-color test-selected-not-cursor-is-not-cursor-color
 :test-unselected-bullet test-unselected-bullet}
