(local ansi (require "vtx.ansi"))

(local util (require "vtx.util"))

(fn hbox [items ?opts]
  (let [gap (or (and ?opts ?opts.gap) 0)
        valign (or (and ?opts ?opts.valign) "top")
        gap-str (util.string-rep " " gap)
        item-data (icollect [_ item (ipairs items)] (let [lines (util.split-lines item)
                                                          w (accumulate [m 0 _ l (ipairs lines)] (math.max m (ansi.len l)))]
                                                      {:lines lines :width w}))
        height (accumulate [m 0 _ d (ipairs item-data)] (math.max m (# d.lines)))
        result {}]
    (for [row 1 height]
      (let [parts {}]
        (each [_ d (ipairs item-data)]
          (let [nlines (# d.lines)
                offset (match valign
                         "bottom" (- height nlines)
                         "center" (math.floor (/ (- height nlines) 2))
                         _ 0)
                idx (- row offset)
                line (if (and (>= idx 1) (<= idx nlines))
                         (. d.lines idx)
                         "")
                padded (.. line (util.string-rep " " (math.max 0 (- d.width (ansi.len line)))))]
            (table.insert parts padded)))
        (table.insert result (table.concat parts gap-str))))
    (table.concat result "\n")))

(fn vbox [items ?opts]
  (let [gap (or (and ?opts ?opts.gap) 0)
        sep (util.string-rep "\n" (+ gap 1))]
    (table.concat items sep)))

(fn grid [items ?opts]
  "Arrange items in a grid. items = list of strings. cols = number of columns.
Each cell is padded to the max cell width in its column. Rows aligned by row height."
  (let [opts (or ?opts {})
        cols (or opts.cols 2)
        gap-h (or opts.gap-h 1)
        gap-v (or opts.gap-v 0)
        n (# items)
        nrows (math.ceil (/ n cols))
        cell-widths {}
        cell-heights {}]
    (each [i item (ipairs items)]
      (let [col (+ (% (- i 1) cols) 1)
            row (+ (math.floor (/ (- i 1) cols)) 1)
            lines (util.split-lines item)
            w (accumulate [m 0 _ l (ipairs lines)] (math.max m (ansi.len l)))
            h (# lines)]
        (tset cell-widths col (math.max (or (. cell-widths col) 0) w))
        (tset cell-heights row (math.max (or (. cell-heights row) 0) h))))
    (let [row-strs {}]
      (for [row 1 nrows]
        (let [row-cells {}]
          (for [col 1 cols]
            (let [i (+ (* (- row 1) cols) col)
                  item (or (. items i) "")
                  lines (util.split-lines item)
                  cw (. cell-widths col)
                  ch (. cell-heights row)
                  padded (let [ls {}]
                           (for [li 1 ch]
                             (let [l (or (. lines li) "")]
                               (table.insert ls (.. l (util.string-rep " " (math.max 0 (- cw (ansi.len l))))))))
                           ls)]
              (table.insert row-cells padded)))
          (let [ch (. cell-heights row)]
            (for [li 1 ch]
              (let [line-parts (icollect [_ cell (ipairs row-cells)] (. cell li))]
                (table.insert row-strs (table.concat line-parts (util.string-rep " " gap-h))))))
          (when (< row nrows)
            (for [_ 1 gap-v]
              (table.insert row-strs "")))))
      (table.concat row-strs "\n"))))

{:grid grid :hbox hbox :vbox vbox}
