(local term (require "vtx.term"))

(local ansi (require "vtx.ansi"))

(local util (require "vtx.util"))

(local theme (require "vtx.theme"))

(local list-nav (require "vtx.list-nav"))

(local default-opts {:header-fg ansi.fg.cyan
                     :height 10
                     :multi false
                     :select true
                     :selected-fg ansi.fg.green
                     :sep "  "
                     :sort-asc true
                     :sort-col nil})

(fn col-widths [headers rows]
  (let [widths {}]
    (each [i h (ipairs headers)]
      (tset widths i (ansi.len h)))
    (each [_ row (ipairs rows)]
      (each [i cell (ipairs row)]
        (let [cw (ansi.len (tostring (or cell "")))]
          (when (> cw (or (. widths i) 0))
            (tset widths i cw)))))
    widths))

(fn render-row [row widths sep]
  (let [cells {}]
    (each [i w (ipairs widths)]
      (let [cell (tostring (or (. row i) ""))
            pad (- w (ansi.len cell))]
        (table.insert cells (.. cell (util.string-rep " " pad)))))
    (table.concat cells sep)))

(fn sort-rows [rows col asc]
  (let [sorted {}]
    (each [_ row (ipairs rows)]
      (table.insert sorted row))
    (table.sort sorted (fn [a b]
                         (let [av (tostring (or (. a col) ""))
                               bv (tostring (or (. b col) ""))
                               an (tonumber av)
                               bn (tonumber bv)]
                           (if (and an bn)
                               (if asc
                                   (< an bn)
                                   (> an bn))
                               (if asc
                                   (< av bv)
                                   (> av bv))))))
    sorted))

(fn tbl [headers rows user-opts]
  (let [opts (theme.merge default-opts user-opts)]
    (when (> (# rows) 0)
      (let [widths (col-widths headers rows)
            n (# rows)
            height (math.min opts.height n)
            ncols (# headers)
            nav (list-nav.make-state n height)
            fcache (term.make-frame-cache)]
        (var result nil)
        (var selected {})
        (var term-w 80)
        (var sort-col opts.sort-col)
        (var sort-asc opts.sort-asc)
        (var cached-rows nil)
        (var cached-key nil)
        (fn sorted []
          (let [key (if sort-col
                        (.. sort-col ":" (tostring sort-asc))
                        "")]
            (when (not= key cached-key)
              (set cached-rows (if sort-col
                                   (sort-rows rows sort-col sort-asc)
                                   rows))
              (set cached-key key))
            cached-rows))
        (term.with-raw (fn []
                         (var running true)
                         (while running
                           (set term-w (let [(_ c) (term.size)]
                                         (or c 80)))
                           (list-nav.clamp nav)
                           (let [display-rows (sorted)
                                 display-headers (let [h {}]
                                                   (each [i hdr (ipairs headers)]
                                                     (if (= i sort-col)
                                                         (table.insert h (.. hdr (if sort-asc
                                                                                     " ↑"
                                                                                     " ↓")))
                                                         (table.insert h hdr)))
                                                   h)
                                 display-widths (let [dw {}]
                                                  (each [i w (ipairs widths)]
                                                    (tset dw i (math.max w (ansi.len (or (. display-headers i) "")))))
                                                  dw)]
                             (term.render-frame fcache (fn [push]
                                                         (push (.. "\r" (util.trunc (ansi.style (render-row display-headers display-widths opts.sep) ansi.bold opts.header-fg) term-w) ansi.screen.clear-right "\r
"))
                                                         (for [row 1 height]
                                                           (let [i (+ nav.offset row)
                                                                 r (. display-rows i)
                                                                 is-cur (and opts.select (= i nav.cursor))
                                                                 is-sel (and opts.multi (. selected i))
                                                                 mark (if opts.multi
                                                                          (if is-sel
                                                                              (ansi.style "● " opts.selected-fg)
                                                                              "○ ")
                                                                          "")]
                                                             (push (.. "\r" (if r
                                                                                (util.trunc (.. mark (if is-cur
                                                                                                         (ansi.style (render-row r display-widths opts.sep) ansi.bold opts.selected-fg)
                                                                                                         (render-row r display-widths opts.sep))) term-w)
                                                                                "") ansi.screen.clear-right "\r
"))))
                                                         (push (ansi.cursor.up (+ height 1)))))
                             (let [k (term.read-key)]
                               (if (list-nav.handle-key nav k)
                                   nil
                                   (match k
                                     "<" (set sort-col (if (not sort-col)
                                                           ncols
                                                           (if (= sort-col 1)
                                                               ncols
                                                               (- sort-col 1))))
                                     ">" (set sort-col (if (not sort-col)
                                                           1
                                                           (if (= sort-col ncols)
                                                               1
                                                               (+ sort-col 1))))
                                     "s" (when sort-col
                                           (set sort-asc (not sort-asc)))
                                     "0" (do
                                           (set sort-col nil)
                                           (set sort-asc true))
                                     " " (when opts.multi
                                           (if (. selected nav.cursor)
                                               (tset selected nav.cursor nil)
                                               (tset selected nav.cursor true)))
                                     (where (or "\r" "\n")) (when opts.select
                                                              (if (and opts.multi (next selected))
                                                                  (let [picks {}
                                                                        idxs []]
                                                                    (each [idx _ (pairs selected)]
                                                                      (table.insert idxs idx))
                                                                    (table.sort idxs)
                                                                    (each [_ idx (ipairs idxs)]
                                                                      (table.insert picks (. display-rows idx)))
                                                                    (set result picks))
                                                                  (set result (. display-rows nav.cursor)))
                                                              (set running false))
                                     (where (or "q" "\003" "escape")) (set running false))))))))
        (term.clear-rows (+ height 1))
        result))))

{:col-widths col-widths :render-row render-row :sort-rows sort-rows :tbl tbl}
