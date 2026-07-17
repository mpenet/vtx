(local ansi (require "vtx.ansi"))

(local multi-form-m (require "vtx.widget.multi-form"))

(local faith (require "faith"))

(local base-opts
  {:active-fg ansi.fg.cyan
   :cursor-char "█"
   :label-fg ansi.fg.white
   :value-fg ansi.fg.white})

(fn test-init-state-input-empty []
  (faith.= "" (. (multi-form-m.init-state {:type "input"}) :value)))

(fn test-init-state-input-with-value []
  (faith.= "hello" (. (multi-form-m.init-state {:opts {:value "hello"} :type "input"}) :value)))

(fn test-init-state-confirm-default-true []
  (faith.= true (. (multi-form-m.init-state {:type "confirm"}) :value)))

(fn test-init-state-confirm-default-false []
  (faith.= false (. (multi-form-m.init-state {:opts {:default false} :type "confirm"}) :value)))

(fn test-init-state-num-zero []
  (faith.= 0 (. (multi-form-m.init-state {:type "num"}) :value)))

(fn test-init-state-num-value []
  (faith.= 42 (. (multi-form-m.init-state {:opts {:value 42} :type "num"}) :value)))

(fn test-init-state-password-empty []
  (faith.= "" (. (multi-form-m.init-state {:type "password"}) :value)))

(fn test-render-field-input-active []
  (let [f {:label "Name" :type "input"}
        s {:value "hi"}
        row (ansi.strip (multi-form-m.render-field f s 1 1 base-opts))]
    (faith.is (: row "find" "Name" 1 true))
    (faith.is (: row "find" "hi" 1 true))
    (faith.is (: row "find" "█" 1 true))))

(fn test-render-field-input-inactive []
  (let [f {:label "Name" :type "input"}
        s {:value "hi"}
        row (ansi.strip (multi-form-m.render-field f s 1 2 base-opts))]
    (faith.= nil (row:find "█" 1 true))))

(fn test-render-field-confirm-true []
  (let [f {:label "Ok?" :type "confirm"}
        s {:value true}
        row (ansi.strip (multi-form-m.render-field f s 1 1 base-opts))]
    (faith.is (: row "find" "Yes" 1 true))
    (faith.is (: row "find" "No" 1 true))))

(fn test-render-field-num []
  (let [f {:label "Count" :type "num"}
        s {:value 7}
        row (ansi.strip (multi-form-m.render-field f s 1 1 base-opts))]
    (faith.is (: row "find" "7" 1 true))))

(fn test-render-field-password-masks []
  (let [f {:label "Pass" :type "password"}
        s {:value "secret"}
        row (ansi.strip (multi-form-m.render-field f s 1 1 base-opts))]
    (faith.= nil (row:find "secret" 1 true))
    (faith.is (: row "find" "•" 1 true))))

{:test-init-state-confirm-default-false test-init-state-confirm-default-false
 :test-init-state-confirm-default-true test-init-state-confirm-default-true
 :test-init-state-input-empty test-init-state-input-empty
 :test-init-state-input-with-value test-init-state-input-with-value
 :test-init-state-num-value test-init-state-num-value
 :test-init-state-num-zero test-init-state-num-zero
 :test-init-state-password-empty test-init-state-password-empty
 :test-render-field-confirm-true test-render-field-confirm-true
 :test-render-field-input-active test-render-field-input-active
 :test-render-field-input-inactive test-render-field-input-inactive
 :test-render-field-num test-render-field-num
 :test-render-field-password-masks test-render-field-password-masks}
