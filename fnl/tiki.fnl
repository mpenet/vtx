(local {:confirm confirm} (require "tiki.widget.confirm"))

(local {:form form} (require "tiki.widget.form"))

(local {:tbl tbl} (require "tiki.widget.table"))

(local {:spin spin :spinners spinners} (require "tiki.widget.spin"))

(local {:input input} (require "tiki.widget.input"))

(local {:write write} (require "tiki.widget.write"))

(local {:choose choose} (require "tiki.widget.choose"))

(local {:filter filter :fuzzy-match fuzzy-match} (require "tiki.widget.filter"))

(local {:borders borders :style style} (require "tiki.widget.style"))

(local {:password password} (require "tiki.widget.password"))

(local {:progress progress} (require "tiki.widget.progress"))

(local {:pager pager} (require "tiki.widget.pager"))

(local ansi (require "tiki.ansi"))

(local term (require "tiki.term"))

(local {:clipboard-copy clipboard-copy :clipboard-paste clipboard-paste} (require "tiki.util"))

(local {:apply apply-theme :built-in themes :get-theme get-theme :set-theme set-theme} (require "tiki.theme"))

{:ansi ansi
 :apply-theme apply-theme
 :borders borders
 :choose choose
 :clipboard-copy clipboard-copy
 :clipboard-paste clipboard-paste
 :confirm confirm
 :filter filter
 :form form
 :fuzzy-match fuzzy-match
 :get-theme get-theme
 :input input
 :pager pager
 :password password
 :progress progress
 :set-theme set-theme
 :spin spin
 :spinners spinners
 :style style
 :tbl tbl
 :term term
 :themes themes
 :write write}
