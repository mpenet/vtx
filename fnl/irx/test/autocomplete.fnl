(local faith (require "faith"))

(fn test-module-loads []
  (let [m (require "irx.widget.autocomplete")]
    (faith.is m)
    (faith.= "function" (type m.autocomplete))))

{:test-module-loads test-module-loads}
