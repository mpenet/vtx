(local ansi (require "irx.ansi"))

(local slider-m (require "irx.widget.slider"))

(local faith (require "faith"))

(local opts
  {:empty-char "─"
   :filled-char "━"
   :max 100
   :min 0
   :thumb-char "●"
   :thumb-fg ansi.fg.cyan
   :width 10})

(fn test-render-slider-start []
  (let [s (ansi.strip (slider-m.render-slider 0 opts))]
    (faith.= "●─────────" s)))

(fn test-render-slider-end []
  (let [s (ansi.strip (slider-m.render-slider 100 opts))]
    (faith.= "━━━━━━━━━●" s)))

(fn test-render-slider-mid []
  (let [o (collect [k v (pairs opts)] k v)
        _ (tset o :width 11)
        s (ansi.strip (slider-m.render-slider 50 o))]
    (faith.= "━━━━━●─────" s)))

(fn test-render-slider-width []
  (let [s (ansi.strip (slider-m.render-slider 50 opts))]
    (faith.= 10 (ansi.len s))))

(fn test-render-slider-has-thumb []
  (let [s (ansi.strip (slider-m.render-slider 50 opts))]
    (faith.is (: s "find" "●" 1 true))))

(fn test-render-slider-has-filled []
  (let [s (ansi.strip (slider-m.render-slider 100 opts))]
    (faith.is (: s "find" "━" 1 true))))

(fn test-render-slider-has-empty []
  (let [s (ansi.strip (slider-m.render-slider 0 opts))]
    (faith.is (: s "find" "─" 1 true))))

(fn test-render-slider-ansi-present []
  (let [s (slider-m.render-slider 50 opts)]
    (faith.is (: s "find" "\027" 1 true))))

(fn test-render-slider-equal-range []
  (let [o {:empty-char "─" :filled-char "━" :max 5 :min 5 :thumb-char "●" :thumb-fg "" :width 5}
        s (ansi.strip (slider-m.render-slider 5 o))]
    (faith.= 5 (ansi.len s))))

{:test-render-slider-ansi-present test-render-slider-ansi-present
 :test-render-slider-end test-render-slider-end
 :test-render-slider-equal-range test-render-slider-equal-range
 :test-render-slider-has-empty test-render-slider-has-empty
 :test-render-slider-has-filled test-render-slider-has-filled
 :test-render-slider-has-thumb test-render-slider-has-thumb
 :test-render-slider-mid test-render-slider-mid
 :test-render-slider-start test-render-slider-start
 :test-render-slider-width test-render-slider-width}
