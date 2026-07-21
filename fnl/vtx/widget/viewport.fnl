(local ansi (require "vtx.ansi"))

(local term (require "vtx.term"))

(local theme (require "vtx.theme"))

(local util (require "vtx.util"))

(local default-opts {:height 10})

(fn viewport [content user-opts]
  (let [opts (theme.merge default-opts user-opts)]
    (let [lines (util.split-lines content)
          n (# lines)
          height (math.min opts.height (math.max 1 n))]
      (var offset 0)
      (term.with-raw (fn []
                       (var running true)
                       (while running
                         (for [row 1 height]
                           (let [line (or (. lines (+ offset row)) "")]
                             (term.write (.. "\r" line ansi.screen.clear-right "\r
"))))
                         (term.cursor-up height)
                         (let [k (term.read-key)
                               max-off (math.max 0 (- n height))]
                           (match k
                             (where (or "up" "k" "\016")) (set offset (math.max 0 (- offset 1)))
                             (where (or "down" "j" "\014")) (set offset (math.min max-off (+ offset 1)))
                             "page-up" (set offset (math.max 0 (- offset height)))
                             "page-down" (set offset (math.min max-off (+ offset height)))
                             "g" (set offset 0)
                             "G" (set offset max-off)
                             (where (or "q" "\003" "escape")) (set running false)
                             "resize" nil)))))
      (term.clear-rows height))))

{:viewport viewport}
