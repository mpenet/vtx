(local vtx (require "vtx"))

(local faith (require "faith"))

(fn test-module-loads []
  (faith.= "table" (type vtx)))

(fn test-widget-exports []
  (faith.= "function" (type vtx.input))
  (faith.= "function" (type vtx.password))
  (faith.= "function" (type vtx.write))
  (faith.= "function" (type vtx.confirm))
  (faith.= "function" (type vtx.choose))
  (faith.= "function" (type vtx.filter))
  (faith.= "function" (type vtx.checklist))
  (faith.= "function" (type vtx.radio))
  (faith.= "function" (type vtx.dialog))
  (faith.= "function" (type vtx.form))
  (faith.= "function" (type vtx.multi-form))
  (faith.= "function" (type vtx.tabs))
  (faith.= "function" (type vtx.tree))
  (faith.= "function" (type vtx.tbl))
  (faith.= "function" (type vtx.pager))
  (faith.= "function" (type vtx.viewport))
  (faith.= "function" (type vtx.spin))
  (faith.= "function" (type vtx.progress))
  (faith.= "function" (type vtx.multi-progress))
  (faith.= "function" (type vtx.multi-spin))
  (faith.= "function" (type vtx.gauge))
  (faith.= "function" (type vtx.sparkline))
  (faith.= "function" (type vtx.slider))
  (faith.= "function" (type vtx.date-picker))
  (faith.= "function" (type vtx.file-picker))
  (faith.= "function" (type vtx.autocomplete))
  (faith.= "function" (type vtx.num-input))
  (faith.= "function" (type vtx.toast))
  (faith.= "function" (type vtx.key-help)))

(fn test-style-exports []
  (faith.= "function" (type vtx.style))
  (faith.= "function" (type vtx.place))
  (faith.= "function" (type vtx.separator))
  (faith.= "function" (type vtx.hbox))
  (faith.= "function" (type vtx.vbox))
  (faith.= "table" (type vtx.borders)))

(fn test-theme-exports []
  (faith.= "function" (type vtx.set-theme))
  (faith.= "function" (type vtx.get-theme))
  (faith.= "function" (type vtx.apply-theme))
  (faith.= "table" (type vtx.themes)))

(fn test-gradient-exports []
  (faith.= "function" (type vtx.gradient-text))
  (faith.= "function" (type vtx.gradient-lines))
  (faith.= "function" (type vtx.gradient-bg-lines)))

(fn test-ansi-term-exposed []
  (faith.= "table" (type vtx.ansi))
  (faith.= "table" (type vtx.term)))

{:test-ansi-term-exposed test-ansi-term-exposed
 :test-gradient-exports test-gradient-exports
 :test-module-loads test-module-loads
 :test-style-exports test-style-exports
 :test-theme-exports test-theme-exports
 :test-widget-exports test-widget-exports}
