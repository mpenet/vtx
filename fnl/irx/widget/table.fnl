(local term (require "irx.term"))

(local ansi (require "irx.ansi"))

(local util (require "irx.util"))

(local theme (require "irx.theme"))

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
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (when (> (# rows) 0)
      (let [widths (col-widths headers rows)
            n (# rows)
            height (math.min opts.height n)
            ncols (# headers)]
        (var offset 0)
        (var cursor 1)
        (var result nil)
        (var selected {})
        (var term-w 80)
        (var sort-col opts.sort-col)
        (var sort-asc opts.sort-asc)
        (fn clamp []
          (set cursor (math.max 1 (math.min cursor n)))
          (when (< cursor (+ offset 1))
            (set offset (- cursor 1)))
          (when (> cursor (+ offset height))
            (set offset (- cursor height))))
        (term.with-raw (fn []
                         (var running true)
                         (while running
                           (set term-w (let [(_ c) (term.size)]
                                         (or c 80)))
                           (clamp)
                           (let [display-rows (if sort-col
                                                  (sort-rows rows sort-col sort-asc)
                                                  rows)
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
                             (term.write (.. "\r" (util.trunc (ansi.style (render-row display-headers display-widths opts.sep) ansi.bold opts.header-fg) term-w) ansi.screen.clear-right "\r
"))
                             (for [row 1 height]
                               (let [i (+ offset row)
                                     r (. display-rows i)
                                     is-cur (and opts.select (= i cursor))
                                     is-sel (and opts.multi (. selected i))
                                     mark (if opts.multi
                                              (if is-sel
                                                  (ansi.style "● " opts.selected-fg)
                                                  "○ ")
                                              "")]
                                 (term.write (.. "\r" (if r
                                                          (util.trunc (.. mark (if is-cur
                                                                                   (ansi.style (render-row r display-widths opts.sep) ansi.bold opts.selected-fg)
                                                                                   (render-row r display-widths opts.sep))) term-w)
                                                          "") ansi.screen.clear-right "\r
"))))
                             (term.cursor-up (+ height 1))
                             (let [k (term.read-key)]
                               (match k
                                 (where (or "up" "k" "\016")) (set cursor (- cursor 1))
                                 (where (or "down" "j" "\014")) (set cursor (+ cursor 1))
                                 "g" (set cursor 1)
                                 "G" (set cursor n)
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
                                       (if (. selected cursor)
                                           (tset selected cursor nil)
                                           (tset selected cursor true)))
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
                                                              (set result (. display-rows cursor)))
                                                          (set running false))
                                 "resize" (set term-w (let [(_ c) (term.size)]
                                                        (or c 80)))
                                 (where (or "q" "\003" "escape")) (set running false)))))))
        (for [_ 1 (+ height 1)]
          (term.write (.. "\r" ansi.screen.clear-right "\r
")))
        (term.cursor-up (+ height 1))
        result))))

{:col-widths col-widths :render-row render-row :sort-rows sort-rows :tbl tbl}
