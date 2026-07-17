(local ansi (require "vtx.ansi"))

(local theme (require "vtx.theme"))

(local bar-chars ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"])

(local default-opts {:fg ansi.fg.cyan :label ""})

(fn sparkline [data user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (if (or (not data) (= (# data) 0))
        ""
        (let [lo (accumulate [m (. data 1) _ v (ipairs data)] (math.min m v))
              hi (accumulate [m (. data 1) _ v (ipairs data)] (math.max m v))
              range (- hi lo)
              chars (icollect [_ v (ipairs data)] (if (= range 0)
                                                      (. bar-chars 4)
                                                      (. bar-chars (math.max 1 (math.min 8 (+ 1 (math.floor (* (/ (- v lo) range) 7))))))))
              label (if (and opts.label (> (# opts.label) 0))
                        (.. opts.label " ")
                        "")]
          (.. label (ansi.style (table.concat chars "") opts.fg))))))

{:bar-chars bar-chars :sparkline sparkline}
