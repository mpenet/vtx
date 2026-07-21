(fn merge [defaults overrides]
  (let [result (collect [k v (pairs (or defaults {}))] k v)]
    (each [k v (pairs (or overrides {}))]
      (tset result k v))
    result))

(fn lookup [km k]
  (var found nil)
  (each [action keys (pairs km) &until found]
    (each [_ candidate (ipairs keys) &until found]
      (when (= k candidate)
        (set found action))))
  found)

(local nav-defaults {:bottom ["G"]
                     :cancel ["q" "\003" "escape"]
                     :confirm ["\r" "\n"]
                     :down ["down" "j" "\014"]
                     :page-down ["page-down" "\006"]
                     :page-up ["page-up" "\002"]
                     :toggle [" "]
                     :top ["g"]
                     :up ["up" "k" "\016"]})

(local text-defaults {:backspace ["\b" "\127"]
                      :cancel ["\003"]
                      :confirm ["\r" "\n"]
                      :delete-forward ["delete" "\004"]
                      :end ["end" "\005"]
                      :home ["home" "\001"]
                      :kill-all ["\021"]
                      :kill-line ["\v"]
                      :kill-word-back ["\023" "\027\127"]
                      :left ["left" "\002"]
                      :paste ["\025"]
                      :right ["right" "\006"]
                      :undo ["\026"]})

{:lookup lookup
 :merge merge
 :nav-defaults nav-defaults
 :text-defaults text-defaults}
