(local {:hbox hbox :vbox vbox} (require "tiki.widget.layout"))

(local {:num-input num-input} (require "tiki.widget.num-input"))

(local {:confirm confirm} (require "tiki.widget.confirm"))

(local {:form form} (require "tiki.widget.form"))

(local {:tbl tbl} (require "tiki.widget.table"))

(local {:multi-spin multi-spin :spin spin :spinners spinners} (require "tiki.widget.spin"))

(local {:input input} (require "tiki.widget.input"))

(local {:write write} (require "tiki.widget.write"))

(local {:choose choose} (require "tiki.widget.choose"))

(local {:filter filter :fuzzy-match fuzzy-match} (require "tiki.widget.filter"))

(local {:borders borders
        :height-of height-of
        :merge merge-style
        :place place
        :separator separator
        :style style
        :width-of width-of} (require "tiki.widget.style"))

(local {:radio radio} (require "tiki.widget.radio"))

(local {:autocomplete autocomplete} (require "tiki.widget.autocomplete"))

(local {:file-picker file-picker} (require "tiki.widget.file-picker"))

(local {:key-help key-help} (require "tiki.widget.key-help"))

(local {:slider slider} (require "tiki.widget.slider"))

(local {:tabs tabs} (require "tiki.widget.tabs"))

(local {:tree tree} (require "tiki.widget.tree"))

(local {:color-at color-at
        :gradient-bg-lines gradient-bg-lines
        :gradient-lines gradient-lines
        :gradient-text gradient-text
        :hex->rgb hex->rgb
        :lerp-color lerp-color
        :parse-stops parse-stops} (require "tiki.gradient"))

(local {:password password} (require "tiki.widget.password"))

(local {:date-picker date-picker} (require "tiki.widget.date-picker"))

(local {:dialog dialog} (require "tiki.widget.dialog"))

(local {:gauge gauge} (require "tiki.widget.gauge"))

(local {:multi-form multi-form} (require "tiki.widget.multi-form"))

(local {:sparkline sparkline} (require "tiki.widget.sparkline"))

(local {:viewport viewport} (require "tiki.widget.viewport"))

(local {:checklist checklist} (require "tiki.widget.checklist"))

(local {:multi-progress multi-progress :progress progress} (require "tiki.widget.progress"))

(local {:pager pager} (require "tiki.widget.pager"))

(local {:toast toast} (require "tiki.widget.toast"))

(local ansi (require "tiki.ansi"))

(local term (require "tiki.term"))

(local {:clipboard-copy clipboard-copy :clipboard-paste clipboard-paste :wrap wrap} (require "tiki.util"))

(local {:apply apply-theme :built-in themes :get-theme get-theme :set-theme set-theme} (require "tiki.theme"))

{:ansi ansi
 :apply-theme apply-theme
 :autocomplete autocomplete
 :borders borders
 :checklist checklist
 :choose choose
 :clipboard-copy clipboard-copy
 :clipboard-paste clipboard-paste
 :color-at color-at
 :confirm confirm
 :date-picker date-picker
 :dialog dialog
 :file-picker file-picker
 :filter filter
 :form form
 :fuzzy-match fuzzy-match
 :gauge gauge
 :get-theme get-theme
 :gradient-bg-lines gradient-bg-lines
 :gradient-lines gradient-lines
 :gradient-text gradient-text
 :hbox hbox
 :height-of height-of
 :hex->rgb hex->rgb
 :input input
 :key-help key-help
 :lerp-color lerp-color
 :merge-style merge-style
 :multi-form multi-form
 :multi-progress multi-progress
 :multi-spin multi-spin
 :num-input num-input
 :pager pager
 :parse-stops parse-stops
 :password password
 :place place
 :progress progress
 :radio radio
 :separator separator
 :set-theme set-theme
 :slider slider
 :sparkline sparkline
 :spin spin
 :spinners spinners
 :style style
 :tabs tabs
 :tbl tbl
 :term term
 :themes themes
 :toast toast
 :tree tree
 :vbox vbox
 :viewport viewport
 :width-of width-of
 :wrap wrap
 :write write}
