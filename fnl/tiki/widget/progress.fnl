(local posix (require "tiki.posix"))

(local ansi (require "tiki.ansi"))

(local util (require "tiki.util"))

(local theme (require "tiki.theme"))

(local default-opts {:bar-fg ansi.fg.green
                     :block-size 4
                     :empty "░"
                     :fill "█"
                     :indeterminate false
                     :title ""
                     :width 40})

(fn render [value total opts]
  (let [pct (if (> total 0)
                (/ value total)
                0)
        filled (math.floor (* pct opts.width))
        bar (.. (util.string-rep opts.fill filled) (util.string-rep opts.empty (- opts.width filled)))
        pct-str (.. (math.floor (* pct 100)) "%")]
    (.. "\r" (ansi.style (.. "[" bar "]") opts.bar-fg) " " pct-str (if (> (# opts.title) 0)
                                                                       (.. " " opts.title)
                                                                       "") ansi.screen.clear-right)))

(fn render-bounce [pos opts]
  (let [bs opts.block-size
        bar (let [b {}]
              (for [i 1 opts.width]
                (if (and (>= i pos) (< i (+ pos bs)))
                    (table.insert b opts.fill)
                    (table.insert b opts.empty)))
              (table.concat b))]
    (.. "\r" (ansi.style (.. "[" bar "]") opts.bar-fg) " ..." (if (> (# opts.title) 0)
                                                                  (.. " " opts.title)
                                                                  "") ansi.screen.clear-right)))

(fn progress [f user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (posix.write ansi.cursor.hide)
    (var bounce-pos 1)
    (var bounce-dir 1)
    (local update (if opts.indeterminate
                      (fn []
                        (posix.write (render-bounce bounce-pos opts))
                        (io.stdout:flush)
                        (let [max-pos (- opts.width opts.block-size)]
                          (set bounce-pos (+ bounce-pos bounce-dir))
                          (when (or (>= bounce-pos max-pos) (<= bounce-pos 1))
                            (set bounce-dir (- bounce-dir)))))
                      (fn [value total]
                        (posix.write (render value (or total 100) opts))
                        (io.stdout:flush))))
    (let [(ok err) (pcall f update)]
      (posix.write (.. "\r" ansi.screen.clear-right ansi.cursor.show))
      (when (not ok)
        (error err)))))

{:progress progress}
