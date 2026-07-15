(local ansi (require "tiki.ansi"))
(local table-m (require "tiki.widget.table"))
(local faith (require "faith"))

;;; col-widths

(fn test-col-widths-basic []
  (let [w (table-m.col-widths ["Name" "Age"] [["Alice" "30"] ["Bob" "25"]])]
    (faith.= 5 (. w 1))
    (faith.= 3 (. w 2))))

(fn test-col-widths-missing-cell []
  (let [w (table-m.col-widths ["X"] [[]])]
    (faith.= 1 (. w 1))))

(fn test-col-widths-cell-longer []
  (faith.= 6 (. (table-m.col-widths ["A"] [["longer"]]) 1)))

(fn test-col-widths-ansi-header []
  ;; ansi.len used for header, byte len for cells — cell wins if longer
  (let [w (table-m.col-widths [(ansi.style "Name" ansi.bold)] [["Alice"]])]
    (faith.= 5 (. w 1))))

(fn test-col-widths-multi-row []
  (faith.= 4 (. (table-m.col-widths ["Hi"] [["x"] ["yyyy"]]) 1)))

(fn test-col-widths-three-cols []
  (let [w (table-m.col-widths ["A" "BB" "CCC"] [["x" "yy" "zzz"] ["long" "b" "c"]])]
    (faith.= 4 (. w 1))
    (faith.= 2 (. w 2))
    (faith.= 3 (. w 3))))

(fn test-col-widths-nil-cell []
  ;; nil cells are treated as "" (zero width); header width wins
  (let [w (table-m.col-widths ["Col"] [[nil]])]
    (faith.= 3 (. w 1))))

(fn test-col-widths-numeric-cell []
  ;; numeric cells: tostring applied → "123" = 3 chars
  (let [w (table-m.col-widths ["N"] [[123]])]
    (faith.= 3 (. w 1))))

(fn test-col-widths-empty-rows []
  (let [w (table-m.col-widths ["Header"] [])]
    (faith.= 6 (. w 1))))

(fn test-col-widths-single-row-single-col []
  (let [w (table-m.col-widths ["H"] [["val"]])]
    (faith.= 3 (. w 1))))

;;; render-row

(fn test-render-row-basic []
  (faith.= "Alice  30 " (table-m.render-row ["Alice" "30"] {1 5 2 3} "  ")))

(fn test-render-row-single-col []
  (faith.= "Hi   " (table-m.render-row ["Hi"] {1 5} "  ")))

(fn test-render-row-sep-char []
  (faith.= "ab |cd " (table-m.render-row ["ab" "cd"] {1 3 2 3} "|")))

(fn test-render-row-multi-sep []
  (faith.= "ab  :: cd " (table-m.render-row ["ab" "cd"] {1 3 2 3} " :: ")))

(fn test-render-row-missing-cell []
  (faith.= "   " (table-m.render-row [] {1 3} "  ")))

(fn test-render-row-exact-width []
  (faith.= "exact" (table-m.render-row ["exact"] {1 5} "|")))

(fn test-render-row-nil-cell []
  ;; nil becomes "" + padding
  (faith.= "   " (table-m.render-row [nil] {1 3} " ")))

(fn test-render-row-numeric-cell []
  ;; numbers tostring'd
  (faith.= "42 " (table-m.render-row [42] {1 3} " ")))

(fn test-render-row-three-cols []
  (let [r (table-m.render-row ["a" "bb" "ccc"] {1 1 2 2 3 3} "-")]
    (faith.= "a-bb-ccc" r)))

(fn test-render-row-padding-fills []
  ;; "hi" in width-5 col → "hi   " (3 spaces pad)
  (let [r (table-m.render-row ["hi"] {1 5} "|")]
    (faith.= "hi   " r)))

{:test-col-widths-basic test-col-widths-basic
 :test-col-widths-missing-cell test-col-widths-missing-cell
 :test-col-widths-cell-longer test-col-widths-cell-longer
 :test-col-widths-ansi-header test-col-widths-ansi-header
 :test-col-widths-multi-row test-col-widths-multi-row
 :test-col-widths-three-cols test-col-widths-three-cols
 :test-col-widths-nil-cell test-col-widths-nil-cell
 :test-col-widths-numeric-cell test-col-widths-numeric-cell
 :test-col-widths-empty-rows test-col-widths-empty-rows
 :test-col-widths-single-row-single-col test-col-widths-single-row-single-col
 :test-render-row-basic test-render-row-basic
 :test-render-row-single-col test-render-row-single-col
 :test-render-row-sep-char test-render-row-sep-char
 :test-render-row-multi-sep test-render-row-multi-sep
 :test-render-row-missing-cell test-render-row-missing-cell
 :test-render-row-exact-width test-render-row-exact-width
 :test-render-row-nil-cell test-render-row-nil-cell
 :test-render-row-numeric-cell test-render-row-numeric-cell
 :test-render-row-three-cols test-render-row-three-cols
 :test-render-row-padding-fills test-render-row-padding-fills}
