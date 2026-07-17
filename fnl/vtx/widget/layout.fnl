(local ansi (require "vtx.ansi"))

(local util (require "vtx.util"))

(fn hbox [items ?opts]
  (let [gap (or (and ?opts ?opts.gap) 0)
        valign (or (and ?opts ?opts.valign) "top")
        gap-str (util.string-rep " " gap)
        item-data (icollect [_ item (ipairs items)]
                    (let [lines (util.split-lines item)
                          w (accumulate [m 0 _ l (ipairs lines)]
                              (math.max m (ansi.len l)))]
                      {:lines lines :width w}))
        height (accumulate [m 0 _ d (ipairs item-data)]
                 (math.max m (# d.lines)))
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
                line (if (and (>= idx 1) (<= idx nlines)) (. d.lines idx) "")
                padded (.. line (util.string-rep " " (math.max 0 (- d.width (ansi.len line)))))]
            (table.insert parts padded)))
        (table.insert result (table.concat parts gap-str))))
    (table.concat result "\n")))

(fn vbox [items ?opts]
  (let [gap (or (and ?opts ?opts.gap) 0)
        sep (util.string-rep "\n" (+ gap 1))]
    (table.concat items sep)))

{:hbox hbox :vbox vbox}
