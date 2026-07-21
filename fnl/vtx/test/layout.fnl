(local ansi (require "vtx.ansi"))

(local layout-m (require "vtx.widget.layout"))

(local util (require "vtx.util"))

(local faith (require "faith"))

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
  (let [r (layout-m.vbox ["a
b"
                          "c
d"])
        lines (util.split-lines r)]
    (faith.= 4 (# lines))
    (faith.= "a" (. lines 1))
    (faith.= "b" (. lines 2))
    (faith.= "c" (. lines 3))
    (faith.= "d" (. lines 4))))

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
  (let [r (layout-m.hbox ["aa
b"
                          "xy
zw"])
        lines (util.split-lines r)]
    (faith.= 2 (# lines))
    (faith.= "aaxy" (. lines 1))
    (faith.= "b zw" (. lines 2))))

(fn test-hbox-height-top []
  (let [r (layout-m.hbox ["a
b
c"
                          "X"] {:valign "top"})
        lines (util.split-lines r)]
    (faith.= 3 (# lines))
    (faith.is (: (. lines 1) "find" "X" 1 true))
    (faith.= false (not (not (: (. lines 2) "find" "X" 1 true))))))

(fn test-hbox-height-bottom []
  (let [r (layout-m.hbox ["a
b
c"
                          "X"] {:valign "bottom"})
        lines (util.split-lines r)]
    (faith.= 3 (# lines))
    (faith.is (: (. lines 3) "find" "X" 1 true))))

(fn test-hbox-height-center []
  (let [nl (string.char 10)
        left (.. "a" nl "b" nl "c" nl "d")
        right (.. "X" nl "Y")
        r (layout-m.hbox [left right] {:valign "center"})
        lines (util.split-lines r)]
    (faith.= 4 (# lines))
    (faith.is (: (. lines 2) "find" "X" 1 true))
    (faith.is (: (. lines 3) "find" "Y" 1 true))))

(fn test-hbox-ansi-width []
  (let [styled (ansi.style "hi" ansi.bold)
        r (layout-m.hbox [styled "ab"])
        lines (util.split-lines r)]
    (faith.= 1 (# lines))
    (faith.= "hiab" (ansi.strip (. lines 1)))))

(fn test-hbox-three-cols []
  (let [r (layout-m.hbox ["a" "b" "c"] {:gap 1})]
    (faith.= "a b c" r)))

(fn test-hbox-equal-height []
  (let [r (layout-m.hbox ["a
b"
                          "c
d"])
        lines (util.split-lines r)]
    (faith.= 2 (# lines))
    (faith.= "ac" (. lines 1))
    (faith.= "bd" (. lines 2))))

(fn test-grid-2x2 []
  (let [r (layout-m.grid ["a" "b" "c" "d"] {:cols 2 :gap-h 0})
        lines (util.split-lines r)]
    (faith.= 2 (# lines))
    (faith.= "ab" (. lines 1))
    (faith.= "cd" (. lines 2))))

(fn test-grid-gap-h []
  (let [r (layout-m.grid ["a" "b" "c" "d"] {:cols 2 :gap-h 2})
        lines (util.split-lines r)]
    (faith.= "a  b" (. lines 1))
    (faith.= "c  d" (. lines 2))))

(fn test-grid-uneven-last-row []
  (let [r (layout-m.grid ["a" "b" "c" "d" "e"] {:cols 3 :gap-h 1})
        lines (util.split-lines r)]
    (faith.= 2 (# lines))
    (faith.= "a b c" (. lines 1))
    (faith.= "d" (: (. lines 2) "sub" 1 1))
    (faith.= "e" (: (. lines 2) "sub" 3 3))))

(fn test-grid-column-widths []
  (let [r (layout-m.grid ["short" "muchlonger" "x" "y"] {:cols 2 :gap-h 1})
        lines (util.split-lines r)]
    (faith.= "short muchlonger" (. lines 1))
    (faith.= "x     y         " (. lines 2))))

(fn test-grid-gap-v []
  (let [r (layout-m.grid ["a" "b" "c" "d"] {:cols 2 :gap-h 0 :gap-v 1})
        lines (util.split-lines r)]
    (faith.= 3 (# lines))
    (faith.= "ab" (. lines 1))
    (faith.= "" (. lines 2))
    (faith.= "cd" (. lines 3))))

(fn test-grid-multiline-cells []
  (let [nl (string.char 10)
        ab (.. "a" nl "b")
        ef (.. "e" nl "f")
        r (layout-m.grid [ab "c" "d" ef] {:cols 2 :gap-h 1})
        lines (util.split-lines r)]
    (faith.= 4 (# lines))
    (faith.= "a c" (. lines 1))
    (faith.= "b  " (. lines 2))
    (faith.= "d e" (. lines 3))
    (faith.= "  f" (. lines 4))))

(fn test-grid-single-item []
  (faith.= "hello" (layout-m.grid ["hello"] {:cols 1})))

(fn test-grid-defaults []
  (let [r (layout-m.grid ["a" "b"])]
    (faith.= "a b" r)))

{:test-grid-2x2 test-grid-2x2
 :test-grid-column-widths test-grid-column-widths
 :test-grid-defaults test-grid-defaults
 :test-grid-gap-h test-grid-gap-h
 :test-grid-gap-v test-grid-gap-v
 :test-grid-multiline-cells test-grid-multiline-cells
 :test-grid-single-item test-grid-single-item
 :test-grid-uneven-last-row test-grid-uneven-last-row
 :test-hbox-ansi-width test-hbox-ansi-width
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
