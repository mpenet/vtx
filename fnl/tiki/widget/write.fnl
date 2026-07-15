(local term (require "tiki.term"))

(local ansi (require "tiki.ansi"))

(local util (require "tiki.util"))

(local theme (require "tiki.theme"))

(local default-opts {:cursor-fg ansi.fg.green
                     :header nil
                     :height 6
                     :on-change nil
                     :prompt "> "
                     :prompt-fg ansi.fg.cyan
                     :value ""
                     :width 60})

(fn cursor-char [line col cursor-fg]
  (let [ch (if (< col (# line))
               (line:sub (+ col 1) (+ col 1))
               " ")]
    (ansi.style ch ansi.reverse cursor-fg)))

(fn render-line [line col is-cursor opts]
  (if is-cursor
      (let [before (line:sub 1 col)
            cur (cursor-char line col opts.cursor-fg)
            after (if (< col (# line))
                      (line:sub (+ col 2))
                      "")]
        (.. before cur after))
      line))

(fn write [user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (var lines (util.split-lines opts.value))
    (var row 1)
    (var col (# (. lines 1)))
    (var offset 0)
    (var result nil)
    (var top-distance 0)
    (var undo-lines (icollect [_ l (ipairs lines)] l))
    (var undo-row 1)
    (var undo-col 0)
    (var prev-content (table.concat lines "\n"))
    (var term-w (let [(_ c) (term.size)]
                  (or c 80)))
    (fn clamp-col []
      (set col (math.min col (# (. lines row)))))
    (fn adjust-viewport []
      (when (< row (+ offset 1))
        (set offset (- row 1)))
      (when (> row (+ offset opts.height))
        (set offset (- row opts.height))))
    (fn header-lines []
      (if opts.header
          1
          0))
    (fn widget-height []
      (+ (header-lines) opts.height 1))
    (term.with-raw (fn []
                     (var running true)
                     (var first-draw true)
                     (while running
                       (when (and (not first-draw) (> top-distance 0))
                         (term.cursor-up top-distance))
                       (set first-draw false)
                       (adjust-viewport)
                       (set term-w (let [(_ c) (term.size)]
                                     (or c 80)))
                       (let [cursor-row-in-view (- row offset)
                             prompt-w (if opts.prompt
                                          (ansi.len opts.prompt)
                                          0)]
                         (when opts.header
                           (term.write (.. "\r" (ansi.style opts.header opts.prompt-fg) ansi.screen.clear-right "\r
")))
                         (for [r 1 opts.height]
                           (let [li (+ offset r)
                                 line (. lines li)
                                 is-cur (= li row)]
                             (term.write (.. "\r" (if opts.prompt
                                                      (ansi.style opts.prompt opts.prompt-fg)
                                                      "") (if line
                                                              (util.trunc (render-line line col is-cur opts) (- term-w prompt-w))
                                                              "") ansi.screen.clear-right "\r
"))))
                         (term.write (.. "\r" (ansi.style (.. "ctrl-d submit · ctrl-c cancel · " (# lines) " line(s)") ansi.dim ansi.fg.white) ansi.screen.clear-right))
                         (term.cursor-up (+ (- opts.height cursor-row-in-view) 1))
                         (term.cursor-col (+ prompt-w (math.min col (math.max 0 (- term-w prompt-w 1))) 1))
                         (set top-distance (+ (header-lines) (- cursor-row-in-view 1))))
                       (let [k (term.read-key)]
                         (when (not= k "\026")
                           (set undo-lines (icollect [_ l (ipairs lines)] l))
                           (set undo-row row)
                           (set undo-col col))
                         (match k
                           "\004" (do
                                    (set result (table.concat lines "\n"))
                                    (set running false))
                           "\003" (set running false)
                           (where (or "\r" "\n")) (let [cur-line (. lines row)
                                                        before (cur-line:sub 1 col)
                                                        after (cur-line:sub (+ col 1))]
                                                    (tset lines row before)
                                                    (table.insert lines (+ row 1) after)
                                                    (set row (+ row 1))
                                                    (set col 0))
                           (where (or "\b" "\127")) (if (> col 0)
                                                        (let [cur-line (. lines row)]
                                                          (tset lines row (.. (cur-line:sub 1 (- col 1)) (cur-line:sub (+ col 1))))
                                                          (set col (- col 1)))
                                                        (when (> row 1)
                                                          (let [prev (. lines (- row 1))
                                                                cur (. lines row)]
                                                            (set col (# prev))
                                                            (tset lines (- row 1) (.. prev cur))
                                                            (table.remove lines row)
                                                            (set row (- row 1)))))
                           "delete" (let [cur-line (. lines row)]
                                      (if (< col (# cur-line))
                                          (tset lines row (.. (cur-line:sub 1 col) (cur-line:sub (+ col 2))))
                                          (when (< row (# lines))
                                            (tset lines row (.. cur-line (. lines (+ row 1))))
                                            (table.remove lines (+ row 1)))))
                           (where (or "left" "\002")) (if (> col 0)
                                                          (set col (- col 1))
                                                          (when (> row 1)
                                                            (set row (- row 1))
                                                            (set col (# (. lines row)))))
                           (where (or "right" "\006")) (let [cur-line (. lines row)]
                                                         (if (< col (# cur-line))
                                                             (set col (+ col 1))
                                                             (when (< row (# lines))
                                                               (set row (+ row 1))
                                                               (set col 0))))
                           (where (or "up" "\016")) (when (> row 1)
                                                      (set row (- row 1))
                                                      (clamp-col))
                           (where (or "down" "\014")) (when (< row (# lines))
                                                        (set row (+ row 1))
                                                        (clamp-col))
                           (where (or "home" "\001")) (set col 0)
                           (where (or "end" "\005")) (set col (# (. lines row)))
                           "\v" (let [cur-line (. lines row)]
                                  (tset lines row (cur-line:sub 1 col)))
                           "\021" (do
                                    (tset lines row "")
                                    (set col 0))
                           (where (or "\023" "\027\127")) (when (> col 0)
                                                            (let [cur-line (. lines row)
                                                                  prefix (cur-line:sub 1 col)
                                                                  suffix (cur-line:sub (+ col 1))
                                                                  new-prefix (prefix:gsub "%S+%s*$" "")]
                                                              (set col (# new-prefix))
                                                              (tset lines row (.. new-prefix suffix))))
                           "\027d" (let [cur-line (. lines row)
                                         suffix (cur-line:sub (+ col 1))
                                         new-suffix (suffix:gsub "^%s*%S+" "")]
                                     (tset lines row (.. (cur-line:sub 1 col) new-suffix)))
                           "\025" (let [text (util.clipboard-paste)]
                                    (when (and text (> (# text) 0))
                                      (let [paste-lines (util.split-lines text)
                                            np (# paste-lines)
                                            cur-line (. lines row)
                                            before (cur-line:sub 1 col)
                                            after (cur-line:sub (+ col 1))]
                                        (if (= np 1)
                                            (do
                                              (tset lines row (.. before (. paste-lines 1) after))
                                              (set col (+ col (# (. paste-lines 1)))))
                                            (do
                                              (tset lines row (.. before (. paste-lines 1)))
                                              (for [pi 2 (- np 1)]
                                                (table.insert lines (+ row pi -1) (. paste-lines pi)))
                                              (table.insert lines (+ row np -1) (.. (. paste-lines np) after))
                                              (set col (# (. paste-lines np)))
                                              (set row (+ row np -1)))))))
                           "\026" (when undo-lines
                                    (let [tl undo-lines
                                          tr undo-row
                                          tc undo-col]
                                      (set undo-lines (icollect [_ l (ipairs lines)] l))
                                      (set undo-row row)
                                      (set undo-col col)
                                      (set lines tl)
                                      (set row tr)
                                      (set col tc)))
                           "\027f" (let [cur-line (. lines row)]
                                     (while (and (< col (# cur-line)) (not (string.match (cur-line:sub (+ col 1) (+ col 1)) "%s")))
                                       (set col (+ col 1)))
                                     (while (and (< col (# cur-line)) (string.match (cur-line:sub (+ col 1) (+ col 1)) "%s"))
                                       (set col (+ col 1))))
                           "\027b" (let [cur-line (. lines row)]
                                     (while (and (> col 0) (string.match (cur-line:sub col col) "%s"))
                                       (set col (- col 1)))
                                     (while (and (> col 0) (not (string.match (cur-line:sub col col) "%s")))
                                       (set col (- col 1))))
                           _ (when (and (= (type k) "string") (= (# k) 1) (>= (string.byte k) 32))
                               (let [cur-line (. lines row)]
                                 (tset lines row (.. (cur-line:sub 1 col) k (cur-line:sub (+ col 1))))
                                 (set col (+ col 1)))))
                         (when opts.on-change
                           (let [content (table.concat lines "\n")]
                             (when (not= content prev-content)
                               (opts.on-change content)
                               (set prev-content content))))))))
    (term.cursor-up top-distance)
    (let [h (widget-height)]
      (for [_ 1 h]
        (term.write (.. "\r" ansi.screen.clear-right "\r
")))
      (term.cursor-up h))
    result))

{:write write}
