(local ansi (require "tiki.ansi"))

(local util (require "tiki.util"))

(local borders {:ascii {:bl "+" :br "+" :h "-" :tl "+" :tr "+" :v "|"}
                :double {:bl "╚" :br "╝" :h "═" :tl "╔" :tr "╗" :v "║"}
                :none {:bl "" :br "" :h "" :tl "" :tr "" :v ""}
                :normal {:bl "└" :br "┘" :h "─" :tl "┌" :tr "┐" :v "│"}
                :rounded {:bl "╰" :br "╯" :h "─" :tl "╭" :tr "╮" :v "│"}
                :thick {:bl "┗" :br "┛" :h "━" :tl "┏" :tr "┓" :v "┃"}})

(fn pad-line [line width align]
  (let [vlen (ansi.len line)
        diff (- width vlen)]
    (if (<= diff 0)
        line
        (match (or align "left")
          "left" (.. line (util.string-rep " " diff))
          "right" (.. (util.string-rep " " diff) line)
          "center" (let [l (math.floor (/ diff 2))
                         r (- diff l)]
                     (.. (util.string-rep " " l) line (util.string-rep " " r)))))))

(fn style [text opts]
  (let [opts (or opts {})
        border-key (or opts.border "none")
        border (or (. borders border-key) borders.none)
        has-border (not= border-key "none")
        pad (if (= (type opts.padding) "number")
                {:bottom opts.padding :left opts.padding :right opts.padding :top opts.padding}
                (or opts.padding {:bottom 0 :left 0 :right 0 :top 0}))
        marg (if (= (type opts.margin) "number")
                 {:bottom opts.margin :left opts.margin :right opts.margin :top opts.margin}
                 (or opts.margin {:bottom 0 :left 0 :right 0 :top 0}))
        wrapped-text (if (and opts.wrap opts.width (> opts.width 0))
                         (util.wrap text opts.width)
                         text)
        lines (util.split-lines wrapped-text)
        max-content (accumulate [m 0 _ l (ipairs lines)] (math.max m (ansi.len l)))
        inner-w (math.max (or opts.width 0) max-content)
        style-pre (.. (if opts.fg
                          opts.fg
                          "") (if opts.bg
                                  opts.bg
                                  "") (if opts.bold
                                          ansi.bold
                                          "") (if opts.italic
                                                  ansi.italic
                                                  "") (if opts.underline
                                                          ansi.underline
                                                          ""))
        style-suf (if (> (# style-pre) 0)
                      ansi.reset
                      "")
        h-line (util.string-rep border.h (+ inner-w pad.left pad.right))
        pad-left (util.string-rep " " pad.left)
        pad-right (util.string-rep " " pad.right)
        margin-left (util.string-rep " " marg.left)
        result {}]
    (for [_ 1 marg.top]
      (table.insert result ""))
    (when has-border
      (table.insert result (.. margin-left border.tl h-line border.tr)))
    (for [_ 1 pad.top]
      (let [bv (if has-border
                   border.v
                   "")]
        (table.insert result (.. margin-left bv pad-left (util.string-rep " " inner-w) pad-right bv))))
    (each [_ line (ipairs lines)]
      (table.insert result (.. margin-left (if has-border
                                               border.v
                                               "") pad-left style-pre (pad-line line inner-w (or opts.align "left")) style-suf pad-right (if has-border
                                                                                                                                             border.v
                                                                                                                                             ""))))
    (for [_ 1 pad.bottom]
      (let [bv (if has-border
                   border.v
                   "")]
        (table.insert result (.. margin-left bv pad-left (util.string-rep " " inner-w) pad-right bv))))
    (when has-border
      (table.insert result (.. margin-left border.bl h-line border.br)))
    (for [_ 1 marg.bottom]
      (table.insert result ""))
    (table.concat result "\n")))

(fn width-of [text]
  (accumulate [m 0 _ l (ipairs (util.split-lines text))] (math.max m (ansi.len l))))

(fn height-of [text]
  (# (util.split-lines text)))

(fn merge [base extra]
  (let [result (collect [k v (pairs (or base {}))] k v)]
    (each [k v (pairs (or extra {}))]
      (tset result k v))
    result))

(fn place [content opts]
  (let [lines (util.split-lines content)
        nlines (# lines)
        w (or opts.width (width-of content))
        h (or opts.height nlines)
        halign (or opts.halign "left")
        valign (or opts.valign "top")
        voff (match valign
               "bottom" (math.max 0 (- h nlines))
               "middle" (math.max 0 (math.floor (/ (- h nlines) 2)))
               _ 0)
        result {}]
    (for [row 1 h]
      (let [li (- row voff)
            raw (if (and (>= li 1) (<= li nlines))
                    (. lines li)
                    "")
            line (if (> (ansi.len raw) w)
                     (util.trunc raw w)
                     raw)
            lw (ansi.len line)
            diff (math.max 0 (- w lw))
            padded (match halign
                     "right" (.. (util.string-rep " " diff) line)
                     "center" (let [l (math.floor (/ diff 2))
                                    r (- diff l)]
                                (.. (util.string-rep " " l) line (util.string-rep " " r)))
                     _ (.. line (util.string-rep " " diff)))]
        (table.insert result padded)))
    (table.concat result "\n")))

(fn separator [opts]
  (let [opts (or opts {})
        w (or opts.width 40)
        label (or opts.label "")
        border-key (or opts.border "normal")
        b (or (. borders border-key) borders.normal)
        fg-pre (or opts.fg "")
        fg-suf (if (> (# fg-pre) 0)
                   ansi.reset
                   "")
        ml (util.string-rep " " (or opts.margin-left 0))]
    (if (= (# label) 0)
        (.. ml fg-pre (util.string-rep b.h w) fg-suf)
        (let [lw (ansi.len label)
              avail (math.max 0 (- w lw 2))
              half (math.floor (/ avail 2))
              right-h (- avail half)]
          (.. ml fg-pre (util.string-rep b.h half) " " label " " (util.string-rep b.h right-h) fg-suf)))))

{:borders borders
 :height-of height-of
 :merge merge
 :place place
 :separator separator
 :style style
 :width-of width-of}
