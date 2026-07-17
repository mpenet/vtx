(local ansi (require "vtx.ansi"))

(local theme (require "vtx.theme"))

(local util (require "vtx.util"))

(local default-opts
  {:bar-fg ansi.fg.green
   :empty "░"
   :fill "█"
   :label ""
   :show-pct true
   :width 20})

(fn gauge [value ?total user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (let [pct (math.max 0 (math.min 1 (if ?total
                                          (if (> ?total 0) (/ value ?total) 0)
                                          value)))
          filled (math.floor (* pct opts.width))
          empty (- opts.width filled)
          bar (.. (ansi.style (util.string-rep opts.fill filled) opts.bar-fg)
                  (util.string-rep opts.empty empty))
          pct-str (if opts.show-pct (string.format " %3d%%" (math.floor (* pct 100))) "")
          label (if (and opts.label (> (# opts.label) 0)) (.. opts.label " ") "")]
      (.. label "[" bar "]" pct-str))))

{:gauge gauge}
