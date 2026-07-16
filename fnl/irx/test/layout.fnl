(local ansi (require "irx.ansi"))

(local layout-m (require "irx.widget.layout"))

(local util (require "irx.util"))

(local faith (require "faith"))

;;; vbox

(fn test-vbox-two-items []
  (let [r (layout-m.vbox ["a" "b"])
        lines (util.split-lines r)]
    (faith.= 2 (# lines))
    (faith.= "a" (. lines 1))
    (faith.= "b" (. lines 2))))

(fn test-vbox-single []
  (faith.= "hello" (layout-m.vbox ["hello"])))

(fn test-vbox-empty []
  (faith.= "" (layout-m.vbox [])))

(fn test-vbox-gap-zero []
  (let [r (layout-m.vbox ["a" "b"] {:gap 0})
        lines (util.split-lines r)]
    (faith.= 2 (# lines))))

(fn test-vbox-gap-one []
  (let [r (layout-m.vbox ["a" "b"] {:gap 1})
        lines (util.split-lines r)]
    (faith.= 3 (# lines))
    (faith.= "a" (. lines 1))
    (faith.= "" (. lines 2))
    (faith.= "b" (. lines 3))))

(fn test-vbox-gap-two []
  (let [r (layout-m.vbox ["x" "y"] {:gap 2})
        lines (util.split-lines r)]
    (faith.= 4 (# lines))
    (faith.= "x" (. lines 1))
    (faith.= "" (. lines 2))
    (faith.= "" (. lines 3))
    (faith.= "y" (. lines 4))))

(fn test-vbox-three-items []
  (let [r (layout-m.vbox ["a" "b" "c"])
        lines (util.split-lines r)]
    (faith.= 3 (# lines))))

(fn test-vbox-multiline-items []
  (let [r (layout-m.vbox ["a\nb" "c\nd"])
        lines (util.split-lines r)]
    (faith.= 4 (# lines))
    (faith.= "a" (. lines 1))
    (faith.= "b" (. lines 2))
    (faith.= "c" (. lines 3))
    (faith.= "d" (. lines 4))))

;;; hbox

(fn test-hbox-two-single-line []
  (let [r (layout-m.hbox ["abc" "xyz"])
        lines (util.split-lines r)]
    (faith.= 1 (# lines))
    (faith.= "abcxyz" (. lines 1))))

(fn test-hbox-empty []
  (faith.= "" (layout-m.hbox [])))

(fn test-hbox-single []
  (faith.= "hello" (layout-m.hbox ["hello"])))

(fn test-hbox-gap []
  (let [r (layout-m.hbox ["ab" "cd"] {:gap 2})]
    (faith.= "ab  cd" r)))

(fn test-hbox-gap-zero []
  (let [r (layout-m.hbox ["ab" "cd"] {:gap 0})]
    (faith.= "abcd" r)))

(fn test-hbox-pads-shorter-lines []
  ; left col has lines "aa" (w=2) and "b" (w=1) — should pad "b" to "b "
  (let [r (layout-m.hbox ["aa\nb" "xy\nzw"])
        lines (util.split-lines r)]
    (faith.= 2 (# lines))
    (faith.= "aaxy" (. lines 1))
    (faith.= "b zw" (. lines 2))))

(fn test-hbox-height-top []
  ; left col: 3 lines, right col: 1 line — top alignment: right line appears at row 1
  (let [r (layout-m.hbox ["a\nb\nc" "X"] {:valign "top"})
        lines (util.split-lines r)]
    (faith.= 3 (# lines))
    (faith.is (: (. lines 1) "find" "X" 1 true))
    (faith.= false (not (not (: (. lines 2) "find" "X" 1 true))))))

(fn test-hbox-height-bottom []
  ; left col: 3 lines, right col: 1 line — bottom alignment: right line appears at row 3
  (let [r (layout-m.hbox ["a\nb\nc" "X"] {:valign "bottom"})
        lines (util.split-lines r)]
    (faith.= 3 (# lines))
    (faith.is (: (. lines 3) "find" "X" 1 true))))

(fn test-hbox-height-center []
  ; left col: 4 lines, right col: 2 lines — center: right lines at rows 2-3
  (let [r (layout-m.hbox ["a\nb\nc\nd" "X\nY"] {:valign "center"})
        lines (util.split-lines r)]
    (faith.= 4 (# lines))
    (faith.is (: (. lines 2) "find" "X" 1 true))
    (faith.is (: (. lines 3) "find" "Y" 1 true))))

(fn test-hbox-ansi-width []
  ; items with ANSI styling — width measured correctly, padding correct
  (let [styled (ansi.style "hi" ansi.bold)
        r (layout-m.hbox [styled "ab"])
        lines (util.split-lines r)]
    (faith.= 1 (# lines))
    (faith.= "hiab" (ansi.strip (. lines 1)))))

(fn test-hbox-three-cols []
  (let [r (layout-m.hbox ["a" "b" "c"] {:gap 1})]
    (faith.= "a b c" r)))

(fn test-hbox-equal-height []
  (let [r (layout-m.hbox ["a\nb" "c\nd"])
        lines (util.split-lines r)]
    (faith.= 2 (# lines))
    (faith.= "ac" (. lines 1))
    (faith.= "bd" (. lines 2))))

{:test-hbox-ansi-width test-hbox-ansi-width
 :test-hbox-empty test-hbox-empty
 :test-hbox-equal-height test-hbox-equal-height
 :test-hbox-gap test-hbox-gap
 :test-hbox-gap-zero test-hbox-gap-zero
 :test-hbox-height-bottom test-hbox-height-bottom
 :test-hbox-height-center test-hbox-height-center
 :test-hbox-height-top test-hbox-height-top
 :test-hbox-pads-shorter-lines test-hbox-pads-shorter-lines
 :test-hbox-single test-hbox-single
 :test-hbox-three-cols test-hbox-three-cols
 :test-hbox-two-single-line test-hbox-two-single-line
 :test-vbox-empty test-vbox-empty
 :test-vbox-gap-one test-vbox-gap-one
 :test-vbox-gap-two test-vbox-gap-two
 :test-vbox-gap-zero test-vbox-gap-zero
 :test-vbox-multiline-items test-vbox-multiline-items
 :test-vbox-single test-vbox-single
 :test-vbox-three-items test-vbox-three-items
 :test-vbox-two-items test-vbox-two-items}
