(local ansi (require "irx.ansi"))

(local confirm-m (require "irx.widget.confirm"))

(local faith (require "faith"))

(local base-opts
  {:affirmative "Yes"
   :negative "No"
   :prompt-fg ansi.fg.cyan
   :selected-attr ansi.bold
   :selected-fg ansi.fg.green
   :unselected-fg ansi.fg.white})

(fn test-render-contains-yes []
  (let [s (confirm-m.render "Pick?" true base-opts)]
    (faith.is (s:find "Yes" 1 true))))

(fn test-render-contains-no []
  (let [s (confirm-m.render "Pick?" true base-opts)]
    (faith.is (s:find "No" 1 true))))

(fn test-render-contains-prompt []
  (let [s (confirm-m.render "Continue?" false base-opts)]
    (faith.is (s:find "Continue?" 1 true))))

(fn test-render-selected-true-yes-has-ansi []
  (let [s (confirm-m.render "?" true base-opts)]
    (faith.is (s:find "\027"))))

(fn test-render-selected-false-no-has-ansi []
  (let [s (confirm-m.render "?" false base-opts)]
    (faith.is (s:find "\027"))))

(fn test-render-stripped-selected-true []
  (let [s (ansi.strip (confirm-m.render "Q?" true base-opts))]
    (faith.is (s:find "Yes" 1 true))
    (faith.is (s:find "No" 1 true))))

(fn test-render-stripped-selected-false []
  (let [s (ansi.strip (confirm-m.render "Q?" false base-opts))]
    (faith.is (s:find "Yes" 1 true))
    (faith.is (s:find "No" 1 true))))

(fn test-render-custom-labels []
  (let [opts (collect [k v (pairs base-opts)] k v)
        _ (tset opts :affirmative "Yep")
        _ (tset opts :negative "Nope")
        s (confirm-m.render "?" true opts)]
    (faith.is (s:find "Yep" 1 true))
    (faith.is (s:find "Nope" 1 true))))

(fn test-render-prompt-appears-before-labels []
  (let [s (ansi.strip (confirm-m.render "Prompt" true base-opts))]
    (faith.is (< (s:find "Prompt" 1 true) (s:find "Yes" 1 true)))))

{:test-render-contains-no test-render-contains-no
 :test-render-contains-prompt test-render-contains-prompt
 :test-render-contains-yes test-render-contains-yes
 :test-render-custom-labels test-render-custom-labels
 :test-render-prompt-appears-before-labels test-render-prompt-appears-before-labels
 :test-render-selected-false-no-has-ansi test-render-selected-false-no-has-ansi
 :test-render-selected-true-yes-has-ansi test-render-selected-true-yes-has-ansi
 :test-render-stripped-selected-false test-render-stripped-selected-false
 :test-render-stripped-selected-true test-render-stripped-selected-true}
