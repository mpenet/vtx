(local {:grid grid :hbox hbox :vbox vbox} (require "vtx.widget.layout"))

(local keymap (require "vtx.keymap"))

(local {:num-input num-input} (require "vtx.widget.num-input"))

(local {:confirm confirm} (require "vtx.widget.confirm"))

(local {:form form} (require "vtx.widget.form"))

(local {:tbl tbl} (require "vtx.widget.table"))

(local {:multi-spin multi-spin :spin spin :spinners spinners} (require "vtx.widget.spin"))

(local {:input input} (require "vtx.widget.input"))

(local {:write write} (require "vtx.widget.write"))

(local {:choose choose} (require "vtx.widget.choose"))

(local {:filter filter :fuzzy-match fuzzy-match} (require "vtx.widget.filter"))

(local {:borders borders
        :height-of height-of
        :merge merge-style
        :place place
        :separator separator
        :style style
        :width-of width-of} (require "vtx.widget.style"))

(local {:radio radio} (require "vtx.widget.radio"))

(local {:autocomplete autocomplete} (require "vtx.widget.autocomplete"))

(local {:file-picker file-picker} (require "vtx.widget.file-picker"))

(local {:key-help key-help} (require "vtx.widget.key-help"))

(local {:slider slider} (require "vtx.widget.slider"))

(local {:tabs tabs} (require "vtx.widget.tabs"))

(local {:tree tree} (require "vtx.widget.tree"))

(local {:color-at color-at
        :gradient-bg-lines gradient-bg-lines
        :gradient-lines gradient-lines
        :gradient-text gradient-text
        :hex->rgb hex->rgb
        :lerp-color lerp-color
        :parse-stops parse-stops} (require "vtx.gradient"))

(local {:password password} (require "vtx.widget.password"))

(local {:date-picker date-picker} (require "vtx.widget.date-picker"))

(local {:dialog dialog} (require "vtx.widget.dialog"))

(local {:gauge gauge} (require "vtx.widget.gauge"))

(local {:multi-form multi-form} (require "vtx.widget.multi-form"))

(local {:sparkline sparkline} (require "vtx.widget.sparkline"))

(local {:viewport viewport} (require "vtx.widget.viewport"))

(local {:checklist checklist} (require "vtx.widget.checklist"))

(local {:multi-progress multi-progress :progress progress} (require "vtx.widget.progress"))

(local {:pager pager} (require "vtx.widget.pager"))

(local {:toast toast} (require "vtx.widget.toast"))

(local ansi (require "vtx.ansi"))

(local term (require "vtx.term"))

(local {:clipboard-copy clipboard-copy :clipboard-paste clipboard-paste :wrap wrap} (require "vtx.util"))

(local {:apply apply-theme :built-in themes :get-theme get-theme :set-theme set-theme} (require "vtx.theme"))

(local widgets {:autocomplete autocomplete
                :checklist checklist
                :choose choose
                :confirm confirm
                :date-picker date-picker
                :dialog dialog
                :file-picker file-picker
                :filter filter
                :form form
                :gauge gauge
                :input input
                :key-help key-help
                :multi-form multi-form
                :multi-progress multi-progress
                :multi-spin multi-spin
                :num-input num-input
                :pager pager
                :password password
                :progress progress
                :radio radio
                :slider slider
                :sparkline sparkline
                :spin spin
                :tabs tabs
                :tbl tbl
                :toast toast
                :tree tree
                :viewport viewport
                :write write})

(local styles {:borders borders
               :grid grid
               :hbox hbox
               :height-of height-of
               :merge merge-style
               :place place
               :separator separator
               :style style
               :vbox vbox
               :width-of width-of})

(local gradients {:bg-lines gradient-bg-lines
                  :color-at color-at
                  :hex->rgb hex->rgb
                  :lerp-color lerp-color
                  :lines gradient-lines
                  :parse-stops parse-stops
                  :text gradient-text})

(local themes-api {:apply apply-theme :built-in themes :get get-theme :set set-theme})

(local util {:clipboard-copy clipboard-copy
             :clipboard-paste clipboard-paste
             :fuzzy-match fuzzy-match
             :spinners spinners
             :wrap wrap})

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
 :gradients gradients
 :grid grid
 :hbox hbox
 :height-of height-of
 :hex->rgb hex->rgb
 :input input
 :key-help key-help
 :keymap keymap
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
 :styles styles
 :tabs tabs
 :tbl tbl
 :term term
 :themes themes
 :themes-api themes-api
 :toast toast
 :tree tree
 :util util
 :vbox vbox
 :viewport viewport
 :widgets widgets
 :width-of width-of
 :wrap wrap
 :write write}
