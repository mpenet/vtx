(local ansi (require "vtx.ansi"))

(local table-m (require "vtx.widget.table"))

(local faith (require "faith"))

(fn test-sort-rows-asc []
  (let [rows [["b"] ["a"] ["c"]]
        r (table-m.sort-rows rows 1 true)]
    (faith.= "a" (. (. r 1) 1))
    (faith.= "b" (. (. r 2) 1))
    (faith.= "c" (. (. r 3) 1))))

(fn test-sort-rows-desc []
  (let [rows [["b"] ["a"] ["c"]]
        r (table-m.sort-rows rows 1 false)]
    (faith.= "c" (. (. r 1) 1))
    (faith.= "b" (. (. r 2) 1))
    (faith.= "a" (. (. r 3) 1))))

(fn test-sort-rows-by-col2 []
  (let [rows [["x" "3"] ["y" "1"] ["z" "2"]]
        r (table-m.sort-rows rows 2 true)]
    (faith.= "y" (. (. r 1) 1))
    (faith.= "z" (. (. r 2) 1))
    (faith.= "x" (. (. r 3) 1))))

(fn test-sort-rows-numeric []
  (let [rows [["10"] ["2"] ["1"]]
        r (table-m.sort-rows rows 1 true)]
    (faith.= "1" (. (. r 1) 1))
    (faith.= "2" (. (. r 2) 1))
    (faith.= "10" (. (. r 3) 1))))

(fn test-sort-rows-preserves-original []
  (let [rows [["b"] ["a"]]
        _ (table-m.sort-rows rows 1 true)]
    (faith.= "b" (. (. rows 1) 1))))

(fn test-sort-rows-empty []
  (faith.= 0 (# (table-m.sort-rows [] 1 true))))

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
  (let [w (table-m.col-widths ["Col"] [[nil]])]
    (faith.= 3 (. w 1))))

(fn test-col-widths-numeric-cell []
  (let [w (table-m.col-widths ["N"] [[123]])]
    (faith.= 3 (. w 1))))

(fn test-col-widths-empty-rows []
  (let [w (table-m.col-widths ["Header"] [])]
    (faith.= 6 (. w 1))))

(fn test-col-widths-single-row-single-col []
  (let [w (table-m.col-widths ["H"] [["val"]])]
    (faith.= 3 (. w 1))))

(fn test-render-row-basic []
  (faith.= "Alice  30 " (table-m.render-row ["Alice" "30"] [5 3] "  ")))

(fn test-render-row-single-col []
  (faith.= "Hi   " (table-m.render-row ["Hi"] [5] "  ")))

(fn test-render-row-sep-char []
  (faith.= "ab |cd " (table-m.render-row ["ab" "cd"] [3 3] "|")))

(fn test-render-row-multi-sep []
  (faith.= "ab  :: cd " (table-m.render-row ["ab" "cd"] [3 3] " :: ")))

(fn test-render-row-missing-cell []
  (faith.= "   " (table-m.render-row [] [3] "  ")))

(fn test-render-row-exact-width []
  (faith.= "exact" (table-m.render-row ["exact"] [5] "|")))

(fn test-render-row-nil-cell []
  (faith.= "   " (table-m.render-row [nil] [3] " ")))

(fn test-render-row-numeric-cell []
  (faith.= "42 " (table-m.render-row [42] [3] " ")))

(fn test-render-row-three-cols []
  (let [r (table-m.render-row ["a" "bb" "ccc"] [1 2 3] "-")]
    (faith.= "a-bb-ccc" r)))

(fn test-render-row-padding-fills []
  (let [r (table-m.render-row ["hi"] [5] "|")]
    (faith.= "hi   " r)))

(fn test-col-widths-sort-indicator-asc []
  (let [headers ["Name ↑" "Stars"]
        rows [["foo" "100"] ["bar" "200"]]
        w (table-m.col-widths headers rows)]
    (faith.= 6 (. w 1))
    (faith.= 5 (. w 2))))

(fn test-col-widths-sort-indicator-desc []
  (let [w (table-m.col-widths ["Stars ↓"] [["100"]])]
    (faith.= 7 (. w 1))))

(fn test-render-row-sort-indicator-alignment []
  (let [headers ["Name ↑" "Age"]
        rows [["Alice" "30"]]
        w (table-m.col-widths headers rows)
        header-row (table-m.render-row headers w "  ")
        data-row (table-m.render-row (. rows 1) w "  ")]
    (faith.= (ansi.len header-row) (ansi.len data-row))))

{:test-col-widths-ansi-header
 test-col-widths-ansi-header
 :test-col-widths-basic
 test-col-widths-basic
 :test-col-widths-cell-longer
 test-col-widths-cell-longer
 :test-col-widths-empty-rows
 test-col-widths-empty-rows
 :test-col-widths-missing-cell
 test-col-widths-missing-cell
 :test-col-widths-multi-row
 test-col-widths-multi-row
 :test-col-widths-nil-cell
 test-col-widths-nil-cell
 :test-col-widths-numeric-cell
 test-col-widths-numeric-cell
 :test-col-widths-single-row-single-col
 test-col-widths-single-row-single-col
 :test-col-widths-sort-indicator-asc
 test-col-widths-sort-indicator-asc
 :test-col-widths-sort-indicator-desc
 test-col-widths-sort-indicator-desc
 :test-col-widths-three-cols
 test-col-widths-three-cols
 :test-render-row-basic
 test-render-row-basic
 :test-render-row-exact-width
 test-render-row-exact-width
 :test-render-row-missing-cell
 test-render-row-missing-cell
 :test-render-row-multi-sep
 test-render-row-multi-sep
 :test-render-row-nil-cell
 test-render-row-nil-cell
 :test-render-row-numeric-cell
 test-render-row-numeric-cell
 :test-render-row-padding-fills
 test-render-row-padding-fills
 :test-render-row-sep-char
 test-render-row-sep-char
 :test-render-row-single-col
 test-render-row-single-col
 :test-render-row-sort-indicator-alignment
 test-render-row-sort-indicator-alignment
 :test-render-row-three-cols
 test-render-row-three-cols
 :test-sort-rows-asc
 test-sort-rows-asc
 :test-sort-rows-by-col2
 test-sort-rows-by-col2
 :test-sort-rows-desc
 test-sort-rows-desc
 :test-sort-rows-empty
 test-sort-rows-empty
 :test-sort-rows-numeric
 test-sort-rows-numeric
 :test-sort-rows-preserves-original
 test-sort-rows-preserves-original}
