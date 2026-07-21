(local ansi (require "vtx.ansi"))

(local built-in {:default
                 {:bar-fg ansi.fg.green
                  :cursor-fg ansi.fg.green
                  :header-fg ansi.fg.cyan
                  :label-fg ansi.fg.cyan
                  :match-fg ansi.fg.yellow
                  :prompt-fg ansi.fg.cyan
                  :selected-attr ansi.bold
                  :selected-fg ansi.fg.green
                  :spinner-fg ansi.fg.cyan
                  :unselected-fg ansi.fg.white}
                 :dracula
                 {:bar-fg (ansi.fg256 141)
                  :cursor-fg (ansi.fg256 141)
                  :header-fg (ansi.fg256 117)
                  :label-fg (ansi.fg256 117)
                  :match-fg (ansi.fg256 228)
                  :prompt-fg (ansi.fg256 141)
                  :selected-attr ansi.bold
                  :selected-fg (ansi.fg256 212)
                  :spinner-fg (ansi.fg256 141)
                  :unselected-fg (ansi.fg256 253)}
                 :gruvbox
                 {:bar-fg (ansi.fg256 214)
                  :cursor-fg (ansi.fg256 214)
                  :header-fg (ansi.fg256 222)
                  :label-fg (ansi.fg256 222)
                  :match-fg (ansi.fg256 229)
                  :prompt-fg (ansi.fg256 208)
                  :selected-attr ansi.bold
                  :selected-fg (ansi.fg256 142)
                  :spinner-fg (ansi.fg256 214)
                  :unselected-fg (ansi.fg256 246)}
                 :light
                 {:bar-fg ansi.fg.blue
                  :cursor-fg ansi.fg.blue
                  :header-fg ansi.fg.blue
                  :label-fg ansi.fg.blue
                  :match-fg ansi.fg.magenta
                  :prompt-fg ansi.fg.blue
                  :selected-attr ansi.bold
                  :selected-fg ansi.fg.blue
                  :spinner-fg ansi.fg.blue
                  :unselected-fg ansi.fg.black}
                 :nord
                 {:bar-fg (ansi.fg256 110)
                  :cursor-fg (ansi.fg256 110)
                  :header-fg (ansi.fg256 111)
                  :label-fg (ansi.fg256 111)
                  :match-fg (ansi.fg256 221)
                  :prompt-fg (ansi.fg256 110)
                  :selected-attr ansi.bold
                  :selected-fg (ansi.fg256 114)
                  :spinner-fg (ansi.fg256 110)
                  :unselected-fg (ansi.fg256 250)}
                 :tron
                 {:active-fg (ansi.fg256 51)
                  :bar-fg (ansi.fg256 46)
                  :cursor-fg (ansi.fg256 46)
                  :header-fg (ansi.fg256 48)
                  :label-fg (ansi.fg256 48)
                  :match-fg (ansi.fg256 226)
                  :prompt-fg (ansi.fg256 40)
                  :selected-attr ansi.bold
                  :selected-fg (ansi.fg256 46)
                  :spinner-fg (ansi.fg256 46)
                  :unselected-fg (ansi.fg256 238)}})

(var current {})

(fn set-theme [name-or-table]
  (if (= (type name-or-table) "string")
      (let [t (. built-in name-or-table)]
        (if t
            (set current (collect [k v (pairs t)] k v))
            (error (.. "vtx: unknown theme: " name-or-table))))
      (= (type name-or-table) "table")
      (set current (collect [k v (pairs name-or-table)] k v))
      (error "vtx: set-theme expects a string name or table")))

(fn merge [default-opts user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (each [k v (pairs current)]
      (when (not= nil (. opts k))
        (tset opts k v)))
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    opts))

(fn get-theme []
  current)

(fn apply [opts]
  "Overrides values in `opts` with the current theme, but only for keys that
already exist in `opts`. Theme keys not present in the widget's default-opts
are silent no-ops. This lets themes ship extra keys (e.g. tron's `:active-fg`,
                                                          consumed only by tabs) without breaking widgets that don't know about them."
  (each [k v (pairs current)]
    (when (not= nil (. opts k))
      (tset opts k v)))
  opts)

{:apply apply
 :built-in built-in
 :get-theme get-theme
 :merge merge
 :set-theme set-theme}
