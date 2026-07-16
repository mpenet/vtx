(local {:hbox hbox :vbox vbox} (require "irx.widget.layout"))

(local {:num-input num-input} (require "irx.widget.num-input"))

(local {:confirm confirm} (require "irx.widget.confirm"))

(local {:form form} (require "irx.widget.form"))

(local {:tbl tbl} (require "irx.widget.table"))

(local {:multi-spin multi-spin :spin spin :spinners spinners} (require "irx.widget.spin"))

(local {:input input} (require "irx.widget.input"))

(local {:write write} (require "irx.widget.write"))

(local {:choose choose} (require "irx.widget.choose"))

(local {:filter filter :fuzzy-match fuzzy-match} (require "irx.widget.filter"))

(local {:borders borders
        :height-of height-of
        :merge merge-style
        :place place
        :separator separator
        :style style
        :width-of width-of} (require "irx.widget.style"))

(local {:radio radio} (require "irx.widget.radio"))

(local {:autocomplete autocomplete} (require "irx.widget.autocomplete"))

(local {:file-picker file-picker} (require "irx.widget.file-picker"))

(local {:key-help key-help} (require "irx.widget.key-help"))

(local {:slider slider} (require "irx.widget.slider"))

(local {:tabs tabs} (require "irx.widget.tabs"))

(local {:tree tree} (require "irx.widget.tree"))

(local {:color-at color-at
        :gradient-bg-lines gradient-bg-lines
        :gradient-lines gradient-lines
        :gradient-text gradient-text
        :hex->rgb hex->rgb
        :lerp-color lerp-color
        :parse-stops parse-stops} (require "irx.gradient"))

(local {:password password} (require "irx.widget.password"))

(local {:date-picker date-picker} (require "irx.widget.date-picker"))

(local {:dialog dialog} (require "irx.widget.dialog"))

(local {:gauge gauge} (require "irx.widget.gauge"))

(local {:multi-form multi-form} (require "irx.widget.multi-form"))

(local {:sparkline sparkline} (require "irx.widget.sparkline"))

(local {:viewport viewport} (require "irx.widget.viewport"))

(local {:checklist checklist} (require "irx.widget.checklist"))

(local {:multi-progress multi-progress :progress progress} (require "irx.widget.progress"))

(local {:pager pager} (require "irx.widget.pager"))

(local {:toast toast} (require "irx.widget.toast"))

(local ansi (require "irx.ansi"))

(local term (require "irx.term"))

(local {:clipboard-copy clipboard-copy :clipboard-paste clipboard-paste :wrap wrap} (require "irx.util"))

(local {:apply apply-theme :built-in themes :get-theme get-theme :set-theme set-theme} (require "irx.theme"))

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
