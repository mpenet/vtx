(local faith (require "faith"))

(fn test-module-loads []
  (let [m (require "vtx.widget.autocomplete")]
    (faith.is m)
    (faith.= "function" (type m.autocomplete))))

{:test-module-loads test-module-loads}
