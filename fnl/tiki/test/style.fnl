(local ansi (require "tiki.ansi"))

(local util (require "tiki.util"))

(local style-m (require "tiki.widget.style"))

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
  (let [lines (util.split-lines (style-m.style "a
b
c" {:border "rounded"}))]
    (faith.= 5 (# lines))))

(fn test-multiline-width-uses-widest []
  (let [lines (util.split-lines (style-m.style "a
long line" {:border "rounded"}))]
    (faith.= (ansi.len (. lines 2)) (ansi.len (. lines 3)))))

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
 :test-italic-stripped test-italic-stripped
 :test-margin-left test-margin-left
 :test-margin-top test-margin-top
 :test-margin-top-bottom test-margin-top-bottom
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
 :test-plain test-plain
 :test-underline-stripped test-underline-stripped
 :test-width-border test-width-border
 :test-width-narrower-than-content test-width-narrower-than-content
 :test-width-no-border test-width-no-border}
