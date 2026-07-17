(local ansi (require :vtx.ansi))
(local theme (require :vtx.theme))
(local faith (require :faith))

(fn setup [] (theme.set-theme {}))
(fn teardown [] (theme.set-theme {}))

(fn test-empty-theme []
  (theme.set-theme {})
  (faith.= nil (next (theme.get-theme))))

(fn test-default-non-empty []
  (theme.set-theme "default")
  (faith.is (next (theme.get-theme))))

(fn test-default-cursor-fg []
  (theme.set-theme "default")
  (faith.= ansi.fg.green (. (theme.get-theme) :cursor-fg)))

(fn test-default-prompt-fg []
  (theme.set-theme "default")
  (faith.= ansi.fg.cyan (. (theme.get-theme) :prompt-fg)))

(fn test-default-selected-fg []
  (theme.set-theme "default")
  (faith.= ansi.fg.green (. (theme.get-theme) :selected-fg)))

(fn test-nord-non-empty []
  (theme.set-theme "nord")
  (faith.is (next (theme.get-theme))))

(fn test-nord-256color []
  (theme.set-theme "nord")
  (faith.is (: (. (theme.get-theme) :cursor-fg) :find "38;5;")))

(fn test-dracula-cursor-fg []
  (theme.set-theme "dracula")
  (faith.is (. (theme.get-theme) :cursor-fg)))

(fn test-gruvbox-match-fg []
  (theme.set-theme "gruvbox")
  (faith.is (. (theme.get-theme) :match-fg)))

(fn test-light-cursor-fg []
  (theme.set-theme "light")
  (faith.= ansi.fg.blue (. (theme.get-theme) :cursor-fg)))

(fn test-light-unselected-fg []
  (theme.set-theme "light")
  (faith.= ansi.fg.black (. (theme.get-theme) :unselected-fg)))

(fn test-invalid-name-throws []
  (faith.error ".*" #(theme.set-theme "doesnotexist")))

(fn test-number-throws []
  (faith.error ".*" #(theme.set-theme 42)))

(fn test-nil-throws []
  (faith.error ".*" #(theme.set-theme nil)))

(fn test-custom-table []
  (theme.set-theme {:cursor-fg "custom-red" :prompt-fg "custom-blue"})
  (faith.= "custom-red" (. (theme.get-theme) :cursor-fg))
  (faith.= "custom-blue" (. (theme.get-theme) :prompt-fg)))

(fn test-apply-known-key []
  (theme.set-theme "default")
  (let [opts {:cursor-fg "old" :height 10}]
    (theme.apply opts)
    (faith.= ansi.fg.green opts.cursor-fg)
    (faith.= 10 opts.height)))

(fn test-apply-no-inject []
  (theme.set-theme {:cursor-fg ansi.fg.red :unknown-key "xyz"})
  (let [opts {:cursor-fg "old"}]
    (theme.apply opts)
    (faith.= ansi.fg.red opts.cursor-fg)
    (faith.= nil opts.unknown-key)))

(fn test-apply-empty-noop []
  (theme.set-theme {})
  (let [opts {:cursor-fg "untouched"}]
    (theme.apply opts)
    (faith.= "untouched" opts.cursor-fg)))

{:setup setup
 :teardown teardown
 :test-empty-theme test-empty-theme
 :test-default-non-empty test-default-non-empty
 :test-default-cursor-fg test-default-cursor-fg
 :test-default-prompt-fg test-default-prompt-fg
 :test-default-selected-fg test-default-selected-fg
 :test-nord-non-empty test-nord-non-empty
 :test-nord-256color test-nord-256color
 :test-dracula-cursor-fg test-dracula-cursor-fg
 :test-gruvbox-match-fg test-gruvbox-match-fg
 :test-light-cursor-fg test-light-cursor-fg
 :test-light-unselected-fg test-light-unselected-fg
 :test-invalid-name-throws test-invalid-name-throws
 :test-number-throws test-number-throws
 :test-nil-throws test-nil-throws
 :test-custom-table test-custom-table
 :test-apply-known-key test-apply-known-key
 :test-apply-no-inject test-apply-no-inject
 :test-apply-empty-noop test-apply-empty-noop}
