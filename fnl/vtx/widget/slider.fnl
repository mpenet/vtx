(local ansi (require "vtx.ansi"))

(local term (require "vtx.term"))

(local theme (require "vtx.theme"))

(local util (require "vtx.util"))

(local default-opts
  {:empty-char "─"
   :filled-char "━"
   :max 100
   :min 0
   :prompt ""
   :step 1
   :thumb-char "●"
   :thumb-fg ansi.fg.cyan
   :value nil
   :width 30})

(fn render-slider [value opts]
  (let [range (- opts.max opts.min)
        t (if (= range 0) 0 (/ (- value opts.min) range))
        w opts.width
        thumb-pos (math.floor (* t (- w 1)))
        filled (util.string-rep opts.filled-char thumb-pos)
        empty (util.string-rep opts.empty-char (- w thumb-pos 1))
        thumb (ansi.style opts.thumb-char opts.thumb-fg)]
    (.. filled thumb empty)))

(fn slider [user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (var value (or opts.value opts.min))
    (var result nil)
    (term.with-raw
      (fn []
        (var running true)
        (while running
          (let [bar (render-slider value opts)
                label (if opts.format-fn (opts.format-fn value) (tostring value))]
            (term.write (.. "\r" opts.prompt bar " " label ansi.screen.clear-right))
            (let [k (term.read-key)]
              (match k
                (where (or "left" "h")) (set value (math.max opts.min (- value opts.step)))
                (where (or "right" "l")) (set value (math.min opts.max (+ value opts.step)))
                "g" (set value opts.min)
                "G" (set value opts.max)
                (where (or "\r" "\n")) (do (set result value) (set running false))
                (where (or "q" "\003" "escape")) (set running false)
                "resize" nil))))))
    (term.write (.. "\r" ansi.screen.clear-right))
    result))

{:render-slider render-slider :slider slider}
