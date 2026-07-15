(local ansi (require "tiki.ansi"))

(local grad (require "tiki.gradient"))

(local faith (require "faith"))

(fn test-hex->rgb-long []
  (let [c (grad.hex->rgb "#ff8000")]
    (faith.= 255 c.r)
    (faith.= 128 c.g)
    (faith.= 0 c.b)))

(fn test-hex->rgb-no-hash []
  (let [c (grad.hex->rgb "ff0000")]
    (faith.= 255 c.r)
    (faith.= 0 c.g)
    (faith.= 0 c.b)))

(fn test-hex->rgb-short []
  (let [c (grad.hex->rgb "#f00")]
    (faith.= 255 c.r)
    (faith.= 0 c.g)
    (faith.= 0 c.b)))

(fn test-hex->rgb-black []
  (let [c (grad.hex->rgb "#000000")]
    (faith.= 0 c.r)
    (faith.= 0 c.g)
    (faith.= 0 c.b)))

(fn test-lerp-color-at-0 []
  (let [c (grad.lerp-color {:b 0 :g 0 :r 255} {:b 255 :g 0 :r 0} 0)]
    (faith.= 255 c.r)
    (faith.= 0 c.b)))

(fn test-lerp-color-at-1 []
  (let [c (grad.lerp-color {:b 0 :g 0 :r 255} {:b 255 :g 0 :r 0} 1)]
    (faith.= 0 c.r)
    (faith.= 255 c.b)))

(fn test-lerp-color-midpoint []
  (let [c (grad.lerp-color {:b 0 :g 0 :r 0} {:b 0 :g 0 :r 100} 0.5)]
    (faith.= 50 c.r)))

(fn test-lerp-color-all-channels []
  (let [c (grad.lerp-color {:b 0 :g 0 :r 0} {:b 200 :g 100 :r 50} 1)]
    (faith.= 50 c.r)
    (faith.= 100 c.g)
    (faith.= 200 c.b)))

(fn test-color-at-two-stops-start []
  (let [red {:b 0 :g 0 :r 255}
        blue {:b 255 :g 0 :r 0}
        c (grad.color-at [red blue] 0)]
    (faith.= 255 c.r)
    (faith.= 0 c.b)))

(fn test-color-at-two-stops-end []
  (let [red {:b 0 :g 0 :r 255}
        blue {:b 255 :g 0 :r 0}
        c (grad.color-at [red blue] 1)]
    (faith.= 0 c.r)
    (faith.= 255 c.b)))

(fn test-color-at-three-stops-mid []
  (let [r {:b 0 :g 0 :r 255}
        g {:b 0 :g 255 :r 0}
        b {:b 255 :g 0 :r 0}
        c (grad.color-at [r g b] 0.5)]
    (faith.= 0 c.r)
    (faith.= 255 c.g)
    (faith.= 0 c.b)))

(fn test-color-at-one-stop []
  (let [red {:b 0 :g 0 :r 255}
        c (grad.color-at [red] 0.5)]
    (faith.= 255 c.r)))

(fn test-gradient-text-has-ansi []
  (let [s (grad.gradient-text "hello" ["#ff0000" "#0000ff"])]
    (faith.is (: s "find" "\027" 1 true))))

(fn test-gradient-text-visible-content []
  (let [s (grad.gradient-text "hi" ["#ff0000" "#0000ff"])]
    (faith.= "hi" (ansi.strip s))))

(fn test-gradient-text-empty []
  (let [s (grad.gradient-text "" ["#ff0000" "#0000ff"])]
    (faith.= "" (ansi.strip s))))

(fn test-gradient-text-single-char []
  (let [s (grad.gradient-text "x" ["#ff0000" "#0000ff"])]
    (faith.= "x" (ansi.strip s))))

(fn test-gradient-text-multiline-preserved []
  (let [s (grad.gradient-text "ab\ncd" ["#ff0000" "#0000ff"])
        stripped (ansi.strip s)]
    (faith.is (: stripped "find" "ab" 1 true))
    (faith.is (: stripped "find" "cd" 1 true))))

(fn test-gradient-lines-count []
  (let [s (grad.gradient-lines "a\nb\nc" ["#ff0000" "#0000ff"])
        lines (icollect [l (s:gmatch "[^\n]+")] l)]
    (faith.= 3 (# lines))))

(fn test-gradient-lines-has-ansi []
  (let [s (grad.gradient-lines "line1\nline2" ["#ff0000" "#0000ff"])]
    (faith.is (: s "find" "\027" 1 true))))

(fn test-gradient-lines-content-preserved []
  (let [s (grad.gradient-lines "foo\nbar" ["#ff0000" "#0000ff"])
        stripped (ansi.strip s)]
    (faith.is (: stripped "find" "foo" 1 true))
    (faith.is (: stripped "find" "bar" 1 true))))

(fn test-gradient-lines-single []
  (let [s (grad.gradient-lines "hello" ["#ff0000" "#0000ff"])]
    (faith.= "hello" (ansi.strip s))))

(fn test-gradient-bg-lines-has-ansi []
  (let [s (grad.gradient-bg-lines "a\nb" ["#ff0000" "#0000ff"])]
    (faith.is (: s "find" "\027" 1 true))))

(fn test-gradient-bg-lines-content-preserved []
  (let [s (grad.gradient-bg-lines "x\ny" ["#ff0000" "#0000ff"])
        stripped (ansi.strip s)]
    (faith.is (: stripped "find" "x" 1 true))
    (faith.is (: stripped "find" "y" 1 true))))

(fn test-gradient-text-truecolor-fg []
  (let [s (grad.gradient-text "x" ["#ff0000" "#0000ff"])]
    (faith.is (: s "find" "38;2;" 1 true))))

(fn test-gradient-bg-lines-truecolor-bg []
  (let [s (grad.gradient-bg-lines "x" ["#ff0000" "#0000ff"])]
    (faith.is (: s "find" "48;2;" 1 true))))

(fn test-parse-stops []
  (let [stops (grad.parse-stops ["#ff0000" "#0000ff"])]
    (faith.= 2 (# stops))
    (faith.= 255 (. stops 1 :r))
    (faith.= 255 (. stops 2 :b))))

{:test-color-at-one-stop test-color-at-one-stop
 :test-color-at-three-stops-mid test-color-at-three-stops-mid
 :test-color-at-two-stops-end test-color-at-two-stops-end
 :test-color-at-two-stops-start test-color-at-two-stops-start
 :test-gradient-bg-lines-content-preserved test-gradient-bg-lines-content-preserved
 :test-gradient-bg-lines-has-ansi test-gradient-bg-lines-has-ansi
 :test-gradient-bg-lines-truecolor-bg test-gradient-bg-lines-truecolor-bg
 :test-gradient-lines-content-preserved test-gradient-lines-content-preserved
 :test-gradient-lines-count test-gradient-lines-count
 :test-gradient-lines-has-ansi test-gradient-lines-has-ansi
 :test-gradient-lines-single test-gradient-lines-single
 :test-gradient-text-empty test-gradient-text-empty
 :test-gradient-text-has-ansi test-gradient-text-has-ansi
 :test-gradient-text-multiline-preserved test-gradient-text-multiline-preserved
 :test-gradient-text-single-char test-gradient-text-single-char
 :test-gradient-text-truecolor-fg test-gradient-text-truecolor-fg
 :test-gradient-text-visible-content test-gradient-text-visible-content
 :test-hex->rgb-black test-hex->rgb-black
 :test-hex->rgb-long test-hex->rgb-long
 :test-hex->rgb-no-hash test-hex->rgb-no-hash
 :test-hex->rgb-short test-hex->rgb-short
 :test-lerp-color-all-channels test-lerp-color-all-channels
 :test-lerp-color-at-0 test-lerp-color-at-0
 :test-lerp-color-at-1 test-lerp-color-at-1
 :test-lerp-color-midpoint test-lerp-color-midpoint
 :test-parse-stops test-parse-stops}
