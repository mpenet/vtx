(local faith (require "faith"))

(fn test-module-loads []
  (let [m (require "irx.widget.viewport")]
    (faith.is m)
    (faith.= "function" (type m.viewport))))

{:test-module-loads test-module-loads}
