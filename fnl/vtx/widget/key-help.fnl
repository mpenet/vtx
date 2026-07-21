(local ansi (require "vtx.ansi"))

(local theme (require "vtx.theme"))

(local default-opts
  {:desc-fg ansi.dim
   :key-fg ansi.bold
   :sep "  "})

(fn key-help [bindings user-opts]
  (let [opts (theme.merge default-opts user-opts)]
    (let [parts (icollect [_ b (ipairs bindings)]
                  (.. (ansi.style b.key opts.key-fg)
                      " "
                      (ansi.style b.desc opts.desc-fg)))]
      (table.concat parts opts.sep))))

{:key-help key-help}
