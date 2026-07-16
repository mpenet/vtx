(local ansi (require "irx.ansi"))

(local toast-m (require "irx.widget.toast"))

(local faith (require "faith"))

(fn test-level-color-info []
  (faith.= ansi.fg.cyan (. toast-m.level-colors :info)))

(fn test-level-color-error []
  (faith.= ansi.fg.red (. toast-m.level-colors :error)))

(fn test-level-color-success []
  (faith.= ansi.fg.green (. toast-m.level-colors :success)))

(fn test-level-color-warn []
  (faith.= ansi.fg.yellow (. toast-m.level-colors :warn)))

(fn test-level-icon-info []
  (faith.= "● " (. toast-m.level-icons :info)))

(fn test-level-icon-error []
  (faith.= "✗ " (. toast-m.level-icons :error)))

(fn test-level-icon-success []
  (faith.= "✓ " (. toast-m.level-icons :success)))

(fn test-level-icon-warn []
  (faith.= "⚠ " (. toast-m.level-icons :warn)))

(fn test-level-colors-four-levels []
  (var n 0)
  (each [_ _ (pairs toast-m.level-colors)]
    (set n (+ n 1)))
  (faith.= 4 n))

(fn test-level-icons-four-levels []
  (var n 0)
  (each [_ _ (pairs toast-m.level-icons)]
    (set n (+ n 1)))
  (faith.= 4 n))

{:test-level-color-error test-level-color-error
 :test-level-color-info test-level-color-info
 :test-level-color-success test-level-color-success
 :test-level-color-warn test-level-color-warn
 :test-level-colors-four-levels test-level-colors-four-levels
 :test-level-icon-error test-level-icon-error
 :test-level-icon-info test-level-icon-info
 :test-level-icon-success test-level-icon-success
 :test-level-icon-warn test-level-icon-warn
 :test-level-icons-four-levels test-level-icons-four-levels}
