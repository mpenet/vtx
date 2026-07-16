(local ansi (require "irx.ansi"))

(local password-m (require "irx.widget.password"))

(local faith (require "faith"))

(local base-opts
  {:confirm false
   :confirm-prompt "Confirm: "
   :cursor-fg ansi.fg.green
   :mask "•"
   :prompt "> "
   :prompt-fg ansi.fg.cyan})

(fn test-render-hidden-masks-chars []
  (let [s (ansi.strip (password-m.render "abc" 0 base-opts nil false))]
    (faith.is (s:find "•" 1 true))
    (faith.= nil (s:find "abc" 1 true))))

(fn test-render-visible-shows-chars []
  (let [s (ansi.strip (password-m.render "abc" 0 base-opts nil true))]
    (faith.is (s:find "a" 1 true))))

(fn test-render-empty-buf-hidden []
  (let [s (ansi.strip (password-m.render "" 0 base-opts nil false))]
    (faith.= nil (s:find "•" 1 true))))

(fn test-render-prompt-appears []
  (let [s (ansi.strip (password-m.render "x" 0 base-opts nil false))]
    (faith.is (s:find "> " 1 true))))

(fn test-render-custom-prompt []
  (let [opts (collect [k v (pairs base-opts)] k v)
        _ (tset opts :prompt "Pass: ")
        s (ansi.strip (password-m.render "x" 0 opts nil false))]
    (faith.is (s:find "Pass: " 1 true))))

(fn test-render-custom-mask []
  (let [opts (collect [k v (pairs base-opts)] k v)
        _ (tset opts :mask "*")
        s (ansi.strip (password-m.render "ab" 0 opts nil false))]
    (faith.is (s:find "*" 1 true))))

(fn test-render-visible-cursor-at-mid []
  (let [s (ansi.strip (password-m.render "abc" 1 base-opts nil true))]
    (faith.is (s:find "a" 1 true))
    (faith.is (s:find "b" 1 true))))

(fn test-render-hidden-mask-count []
  (let [s (ansi.strip (password-m.render "ab" 2 base-opts nil false))
        _ (s:gsub "•" "")]
    (faith.is (>= (# s) 2))))

(fn test-render-has-ansi []
  (let [s (password-m.render "x" 0 base-opts nil false)]
    (faith.is (s:find "\027"))))

(fn test-render-prompt-str-override []
  (let [s (ansi.strip (password-m.render "x" 0 base-opts "Custom: " false))]
    (faith.is (s:find "Custom: " 1 true))))

{:test-render-custom-mask test-render-custom-mask
 :test-render-custom-prompt test-render-custom-prompt
 :test-render-empty-buf-hidden test-render-empty-buf-hidden
 :test-render-has-ansi test-render-has-ansi
 :test-render-hidden-mask-count test-render-hidden-mask-count
 :test-render-hidden-masks-chars test-render-hidden-masks-chars
 :test-render-prompt-appears test-render-prompt-appears
 :test-render-prompt-str-override test-render-prompt-str-override
 :test-render-visible-cursor-at-mid test-render-visible-cursor-at-mid
 :test-render-visible-shows-chars test-render-visible-shows-chars}
