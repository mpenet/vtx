(local term (require "tiki.term"))

(local ansi (require "tiki.ansi"))

(local util (require "tiki.util"))

(local theme (require "tiki.theme"))

(local default-opts {:header-fg ansi.fg.cyan
                     :height 10
                     :select true
                     :selected-fg ansi.fg.green
                     :sep "  "})

(fn col-widths [headers rows]
  (let [widths {}]
    (each [i h (ipairs headers)]
      (tset widths i (ansi.len h)))
    (each [_ row (ipairs rows)]
      (each [i cell (ipairs row)]
        (let [cw (# (tostring (or cell "")))]
          (when (> cw (or (. widths i) 0))
            (tset widths i cw)))))
    widths))

(fn render-row [row widths sep]
  (let [cells {}]
    (each [i w (ipairs widths)]
      (let [cell (tostring (or (. row i) ""))
            pad (- w (# cell))]
        (table.insert cells (.. cell (util.string-rep " " pad)))))
    (table.concat cells sep)))

(fn tbl [headers rows user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (when (> (# rows) 0)
      (let [widths (col-widths headers rows)
            n (# rows)
            height (math.min opts.height n)]
        (var offset 0)
        (var cursor 1)
        (var result nil)
        (var term-w 80)
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
                           (term.write (.. "\r" (util.trunc (ansi.style (render-row headers widths opts.sep) ansi.bold opts.header-fg) term-w) ansi.screen.clear-right "\r
"))
                           (for [row 1 height]
                             (let [i (+ offset row)
                                   r (. rows i)
                                   is-cur (and opts.select (= i cursor))]
                               (term.write (.. "\r" (if r
                                                        (util.trunc (if is-cur
                                                                        (ansi.style (render-row r widths opts.sep) ansi.bold opts.selected-fg)
                                                                        (render-row r widths opts.sep)) term-w)
                                                        "") ansi.screen.clear-right "\r
"))))
                           (term.cursor-up (+ height 1))
                           (let [k (term.read-key)]
                             (match k
                               (where (or "up" "k" "\016")) (set cursor (- cursor 1))
                               (where (or "down" "j" "\014")) (set cursor (+ cursor 1))
                               "g" (set cursor 1)
                               "G" (set cursor n)
                               (where (or "\r" "\n")) (when opts.select
                                                        (set result (. rows cursor))
                                                        (set running false))
                               (where (or "q" "\003")) (set running false))))))
        (for [_ 1 (+ height 1)]
          (term.write (.. "\r" ansi.screen.clear-right "\r
")))
        (term.cursor-up (+ height 1))
        result))))

{:col-widths col-widths :render-row render-row :tbl tbl}
