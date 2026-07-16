(local ansi (require "irx.ansi"))

(local util (require "irx.util"))

(local style-m (require "irx.widget.style"))

(local faith (require "faith"))

(fn test-plain []
  (faith.= "hello" (style-m.style "hello")))

(fn test-multi-word []
  (faith.= "hello world" (style-m.style "hello world")))

(fn test-nil-opts []
  (faith.= "x" (style-m.style "x" nil)))

(fn test-empty-text []
  (faith.= "" (style-m.style "")))

(fn test-bold-stripped []
  (faith.= "hello" (ansi.strip (style-m.style "hello" {:bold true}))))

(fn test-fg-stripped []
  (faith.= "hello" (ansi.strip (style-m.style "hello" {:fg ansi.fg.red}))))

(fn test-bg-stripped []
  (faith.= "hi" (ansi.strip (style-m.style "hi" {:bg ansi.bg.blue}))))

(fn test-italic-stripped []
  (faith.= "hi" (ansi.strip (style-m.style "hi" {:italic true}))))

(fn test-underline-stripped []
  (faith.= "hi" (ansi.strip (style-m.style "hi" {:underline true}))))

(fn test-bold-esc []
  (let [s (style-m.style "x" {:bold true})]
    (faith.is (: s "find" "\027"))))

(fn test-fg-bg-combined []
  (faith.= "x" (ansi.strip (style-m.style "x" {:bg ansi.bg.red :fg ansi.fg.white}))))

(fn test-border-rounded []
  (let [lines (util.split-lines (style-m.style "hello" {:border "rounded"}))]
    (faith.= 3 (# lines))
    (faith.is (: (. lines 1) "find" "╭" 1 true))
    (faith.is (: (. lines 1) "find" "╮" 1 true))
    (faith.is (: (. lines 2) "find" "│" 1 true))
    (faith.is (: (. lines 3) "find" "╰" 1 true))
    (faith.is (: (. lines 3) "find" "╯" 1 true))))

(fn test-border-double []
  (let [lines (util.split-lines (style-m.style "hi" {:border "double"}))]
    (faith.= 3 (# lines))
    (faith.is (: (. lines 1) "find" "╔" 1 true))
    (faith.is (: (. lines 3) "find" "╝" 1 true))))

(fn test-border-thick []
  (let [lines (util.split-lines (style-m.style "hi" {:border "thick"}))]
    (faith.= 3 (# lines))
    (faith.is (: (. lines 1) "find" "┏" 1 true))
    (faith.is (: (. lines 3) "find" "┛" 1 true))))

(fn test-border-normal []
  (let [lines (util.split-lines (style-m.style "hi" {:border "normal"}))]
    (faith.= 3 (# lines))
    (faith.is (: (. lines 1) "find" "┌" 1 true))
    (faith.is (: (. lines 3) "find" "└" 1 true))))

(fn test-border-ascii []
  (let [lines (util.split-lines (style-m.style "hi" {:border "ascii"}))]
    (faith.= 3 (# lines))
    (faith.is (: (. lines 1) "find" "+" 1 true))
    (faith.is (: (. lines 1) "find" "%-" 1))))

(fn test-border-none []
  (let [out (style-m.style "hi" {:border "none"})]
    (faith.= 1 (# (util.split-lines out)))
    (faith.= "hi" out)))

(fn test-border-unknown-fallback []
  (let [out (style-m.style "hi" {:border "nonexistent"})]
    (faith.is (: out "find" "hi" 1 true))))

(fn test-border-content-preserved []
  (let [lines (util.split-lines (style-m.style "hello" {:border "rounded"}))]
    (faith.is (: (. lines 2) "find" "hello" 1 true))))

(fn test-border-empty-text []
  (let [lines (util.split-lines (style-m.style "" {:border "rounded"}))]
    (faith.= 3 (# lines))))

(fn test-padding-uniform []
  (let [lines (util.split-lines (style-m.style "hi" {:border "rounded" :padding 1}))]
    (faith.= 5 (# lines))))

(fn test-padding-asymmetric []
  (let [lines (util.split-lines (style-m.style "hi" {:border "rounded" :padding {:bottom 2 :left 1 :right 1 :top 0}}))]
    (faith.= 5 (# lines))))

(fn test-padding-top3 []
  (let [lines (util.split-lines (style-m.style "hi" {:border "rounded" :padding {:bottom 0 :left 0 :right 0 :top 3}}))]
    (faith.= 6 (# lines))))

(fn test-padding-no-border []
  (let [lines (util.split-lines (style-m.style "hi" {:padding 1}))]
    (faith.= 3 (# lines))))

(fn test-padding-no-border-content []
  (let [lines (util.split-lines (style-m.style "hi" {:padding 1}))]
    (faith.is (: (. lines 2) "find" "hi" 1 true))))

(fn test-margin-left []
  (let [lines (util.split-lines (style-m.style "hi" {:border "rounded" :margin {:bottom 0 :left 3 :right 0 :top 0}}))]
    (faith.= 3 (# lines))
    (faith.is (: (. lines 1) "find" "^   "))))

(fn test-margin-top []
  (let [lines (util.split-lines (style-m.style "hi" {:border "rounded" :margin {:bottom 0 :left 0 :right 0 :top 2}}))]
    (faith.= 5 (# lines))
    (faith.= "" (. lines 1))
    (faith.= "" (. lines 2))))

(fn test-margin-top-bottom []
  (let [out (style-m.style "hi" {:border "rounded" :margin {:bottom 1 :left 0 :right 0 :top 1}})
        lines (util.split-lines out)]
    (faith.= "" (. lines 1))
    (faith.is (: out "find" "
$"))))

(fn test-align-left []
  (faith.= "hi    " (style-m.style "hi" {:align "left" :width 6})))

(fn test-align-right []
  (faith.= "    hi" (style-m.style "hi" {:align "right" :width 6})))

(fn test-align-center []
  (faith.= "  hi  " (style-m.style "hi" {:align "center" :width 6})))

(fn test-align-center-odd []
  (faith.= "  hi   " (style-m.style "hi" {:align "center" :width 7})))

(fn test-align-default-is-left []
  (faith.= "hi  " (style-m.style "hi" {:width 4})))

(fn test-width-border []
  (let [lines (util.split-lines (style-m.style "hi" {:border "rounded" :width 10}))]
    (faith.= 12 (ansi.len (. lines 1)))))

(fn test-width-no-border []
  (faith.= "short     " (style-m.style "short" {:width 10})))

(fn test-width-narrower-than-content []
  (let [out (style-m.style "hello" {:width 2})]
    (faith.= "hello" out)))

(fn test-borders-export []
  (faith.is (. style-m.borders "rounded")))

(fn test-borders-rounded-chars []
  (let [b (. style-m.borders "rounded")]
    (faith.= "╭" b.tl)
    (faith.= "╮" b.tr)
    (faith.= "╰" b.bl)
    (faith.= "╯" b.br)
    (faith.= "─" b.h)
    (faith.= "│" b.v)))

(fn test-borders-all-keys []
  (each [name _ (pairs style-m.borders)]
    (faith.is (. style-m.borders name))))

(fn test-multiline []
  (let [lines (util.split-lines (style-m.style "ab
cd" {:border "rounded"}))]
    (faith.= 4 (# lines))
    (faith.is (: (. lines 2) "find" "ab" 1 true))
    (faith.is (: (. lines 3) "find" "cd" 1 true))))

(fn test-multiline-3 []
  (let [nl (string.char 10)
        lines (util.split-lines (style-m.style (.. "a" nl "b" nl "c") {:border "rounded"}))]
    (faith.= 5 (# lines))))

(fn test-multiline-width-uses-widest []
  (let [lines (util.split-lines (style-m.style "a
long line" {:border "rounded"}))]
    (faith.= (ansi.len (. lines 2)) (ansi.len (. lines 3)))))

(fn test-width-of-single []
  (faith.= 5 (style-m.width-of "hello")))

(fn test-width-of-multiline []
  (faith.= 9 (style-m.width-of "hi
long word
abc")))

(fn test-width-of-ansi []
  (faith.= 5 (style-m.width-of (ansi.style "hello" ansi.bold))))

(fn test-width-of-empty []
  (faith.= 0 (style-m.width-of "")))

(fn test-height-of-single []
  (faith.= 1 (style-m.height-of "hello")))

(fn test-height-of-two []
  (faith.= 2 (style-m.height-of "a
b")))

(fn test-height-of-three []
  (faith.= 3 (style-m.height-of "a
b
c")))

(fn test-merge-basic []
  (let [s (style-m.merge {:bold true :fg "red"} {:fg "blue"})]
    (faith.= "blue" s.fg)
    (faith.= true s.bold)))

(fn test-merge-nil-base []
  (faith.= "blue" (. (style-m.merge nil {:fg "blue"}) "fg")))

(fn test-merge-nil-extra []
  (faith.= "red" (. (style-m.merge {:fg "red"} nil) "fg")))

(fn test-merge-both-nil []
  (faith.= 0 (accumulate [n 0 _ _ (pairs (style-m.merge nil nil))] (+ n 1))))

(fn test-place-pads-right []
  (faith.= "hello     " (style-m.place "hello" {:width 10})))

(fn test-place-align-right []
  (faith.= "     hello" (style-m.place "hello" {:halign "right" :width 10})))

(fn test-place-align-center []
  (faith.= "  hi  " (style-m.place "hi" {:halign "center" :width 6})))

(fn test-place-height-adds-lines []
  (faith.= 3 (style-m.height-of (style-m.place "hello" {:height 3 :width 10}))))

(fn test-place-valign-bottom []
  (let [lines (util.split-lines (style-m.place "x" {:height 3 :valign "bottom" :width 4}))]
    (faith.= "    " (. lines 1))
    (faith.= "    " (. lines 2))
    (faith.is (: (. lines 3) "find" "x" 1 true))))

(fn test-place-valign-middle []
  (let [lines (util.split-lines (style-m.place "x" {:height 3 :valign "middle" :width 4}))]
    (faith.is (: (. lines 2) "find" "x" 1 true))))

(fn test-place-no-opts []
  (faith.= "hello" (style-m.place "hello" {})))

(fn test-separator-width []
  (let [s (style-m.separator {:width 10})]
    (faith.= 10 (ansi.len s))))

(fn test-separator-with-label []
  (let [s (ansi.strip (style-m.separator {:label "hi" :width 20}))]
    (faith.is (: s "find" "hi" 1 true))))

(fn test-separator-no-opts []
  (let [s (style-m.separator {})]
    (faith.= 40 (ansi.len s))))

(fn test-separator-label-total-width []
  (let [s (ansi.strip (style-m.separator {:label "x" :width 11}))]
    (faith.= 11 (ansi.len s))))

(fn test-separator-none-border []
  (let [s (style-m.separator {:border "none" :width 5})]
    (faith.= "" s)))

(fn test-separator-rounded []
  (let [s (ansi.strip (style-m.separator {:border "rounded" :width 10}))]
    (faith.is (: s "find" "─" 1 true))))

(fn test-separator-label-centered []
  (let [s (ansi.strip (style-m.separator {:label "x" :width 11}))]
    (faith.is (: s "find" "x" 1 true))))

(fn test-wrap-in-style []
  (let [lines (util.split-lines (style-m.style "hello world" {:width 5 :wrap true}))]
    (faith.= 2 (# lines))))

{:test-align-center test-align-center
 :test-align-center-odd test-align-center-odd
 :test-align-default-is-left test-align-default-is-left
 :test-align-left test-align-left
 :test-align-right test-align-right
 :test-bg-stripped test-bg-stripped
 :test-bold-esc test-bold-esc
 :test-bold-stripped test-bold-stripped
 :test-border-ascii test-border-ascii
 :test-border-content-preserved test-border-content-preserved
 :test-border-double test-border-double
 :test-border-empty-text test-border-empty-text
 :test-border-none test-border-none
 :test-border-normal test-border-normal
 :test-border-rounded test-border-rounded
 :test-border-thick test-border-thick
 :test-border-unknown-fallback test-border-unknown-fallback
 :test-borders-all-keys test-borders-all-keys
 :test-borders-export test-borders-export
 :test-borders-rounded-chars test-borders-rounded-chars
 :test-empty-text test-empty-text
 :test-fg-bg-combined test-fg-bg-combined
 :test-fg-stripped test-fg-stripped
 :test-height-of-single test-height-of-single
 :test-height-of-three test-height-of-three
 :test-height-of-two test-height-of-two
 :test-italic-stripped test-italic-stripped
 :test-margin-left test-margin-left
 :test-margin-top test-margin-top
 :test-margin-top-bottom test-margin-top-bottom
 :test-merge-basic test-merge-basic
 :test-merge-both-nil test-merge-both-nil
 :test-merge-nil-base test-merge-nil-base
 :test-merge-nil-extra test-merge-nil-extra
 :test-multi-word test-multi-word
 :test-multiline test-multiline
 :test-multiline-3 test-multiline-3
 :test-multiline-width-uses-widest test-multiline-width-uses-widest
 :test-nil-opts test-nil-opts
 :test-padding-asymmetric test-padding-asymmetric
 :test-padding-no-border test-padding-no-border
 :test-padding-no-border-content test-padding-no-border-content
 :test-padding-top3 test-padding-top3
 :test-padding-uniform test-padding-uniform
 :test-place-align-center test-place-align-center
 :test-place-align-right test-place-align-right
 :test-place-height-adds-lines test-place-height-adds-lines
 :test-place-no-opts test-place-no-opts
 :test-place-pads-right test-place-pads-right
 :test-place-valign-bottom test-place-valign-bottom
 :test-place-valign-middle test-place-valign-middle
 :test-plain test-plain
 :test-separator-label-centered test-separator-label-centered
 :test-separator-label-total-width test-separator-label-total-width
 :test-separator-no-opts test-separator-no-opts
 :test-separator-none-border test-separator-none-border
 :test-separator-rounded test-separator-rounded
 :test-separator-width test-separator-width
 :test-separator-with-label test-separator-with-label
 :test-underline-stripped test-underline-stripped
 :test-width-border test-width-border
 :test-width-narrower-than-content test-width-narrower-than-content
 :test-width-no-border test-width-no-border
 :test-width-of-ansi test-width-of-ansi
 :test-width-of-empty test-width-of-empty
 :test-width-of-multiline test-width-of-multiline
 :test-width-of-single test-width-of-single
 :test-wrap-in-style test-wrap-in-style}
