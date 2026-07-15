(local ansi (require "tiki.ansi"))

(local util (require "tiki.util"))

(local borders {:ascii {:bl "+" :br "+" :h "-" :tl "+" :tr "+" :v "|"}
                :double {:bl "╚" :br "╝" :h "═" :tl "╔" :tr "╗" :v "║"}
                :none {:bl "" :br "" :h "" :tl "" :tr "" :v ""}
                :normal {:bl "└" :br "┘" :h "─" :tl "┌" :tr "┐" :v "│"}
                :rounded {:bl "╰" :br "╯" :h "─" :tl "╭" :tr "╮" :v "│"}
                :thick {:bl "┗" :br "┛" :h "━" :tl "┏" :tr "┓" :v "┃"}})

(fn string-rep [s n]
  (let [t {}]
    (for [_ 1 n]
      (table.insert t s))
    (table.concat t)))

(fn pad-line [line width align]
  (let [vlen (ansi.len line)
        diff (- width vlen)]
    (if (<= diff 0)
        line
        (match (or align "left")
          "left" (.. line (string-rep " " diff))
          "right" (.. (string-rep " " diff) line)
          "center" (let [l (math.floor (/ diff 2))
                         r (- diff l)]
                     (.. (string-rep " " l) line (string-rep " " r)))))))

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
        lines (util.split-lines text)
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
        h-line (string-rep border.h (+ inner-w pad.left pad.right))
        pad-left (string-rep " " pad.left)
        pad-right (string-rep " " pad.right)
        margin-left (string-rep " " marg.left)
        result {}]
    (for [_ 1 marg.top]
      (table.insert result ""))
    (when has-border
      (table.insert result (.. margin-left border.tl h-line border.tr)))
    (for [_ 1 pad.top]
      (table.insert result (.. margin-left (if has-border
                                               border.v
                                               "") pad-left (string-rep " " inner-w) pad-right (if has-border
                                                                                                   border.v
                                                                                                   ""))))
    (each [_ line (ipairs lines)]
      (table.insert result (.. margin-left (if has-border
                                               border.v
                                               "") pad-left style-pre (pad-line line inner-w (or opts.align "left")) style-suf pad-right (if has-border
                                                                                                                                             border.v
                                                                                                                                             ""))))
    (for [_ 1 pad.bottom]
      (table.insert result (.. margin-left (if has-border
                                               border.v
                                               "") pad-left (string-rep " " inner-w) pad-right (if has-border
                                                                                                   border.v
                                                                                                   ""))))
    (when has-border
      (table.insert result (.. margin-left border.bl h-line border.br)))
    (for [_ 1 marg.bottom]
      (table.insert result ""))
    (table.concat result "\n")))

{:borders borders :style style}
