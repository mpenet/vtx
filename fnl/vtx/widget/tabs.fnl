(local ansi (require "vtx.ansi"))

(local term (require "vtx.term"))

(local theme (require "vtx.theme"))

(local util (require "vtx.util"))

(local default-opts
  {:active-fg ansi.fg.cyan
   :inactive-fg ansi.dim})

(fn render-tab-bar [tab-list active-i opts ?term-w]
  (let [term-w (or ?term-w 80)
        tabs (icollect [i tab (ipairs tab-list)]
               {:active (= i active-i)
                :label tab.label
                :w (+ 2 (# tab.label))})
        tab-row-w (accumulate [s 0 _ t (ipairs tabs)]
                    (+ s t.w 2))
        row0 (table.concat
               (icollect [_ t (ipairs tabs)]
                 (if t.active
                     (ansi.style (.. "╭" (string.rep "─" t.w) "╮") opts.active-fg)
                     (string.rep " " (+ t.w 2)))))
        row1 (table.concat
               (icollect [_ t (ipairs tabs)]
                 (if t.active
                     (ansi.style (.. "│ " t.label " │") ansi.bold opts.active-fg)
                     (ansi.style (.. "  " t.label "  ") opts.inactive-fg))))
        row2 (.. (table.concat
                   (icollect [_ t (ipairs tabs)]
                     (if t.active
                         (ansi.style (.. "╰" (string.rep "─" t.w) "╯") opts.active-fg)
                         (ansi.style (string.rep "─" (+ t.w 2)) opts.active-fg))))
                 (ansi.style (string.rep "─" (math.max 0 (- term-w tab-row-w))) opts.active-fg))]
    (.. row0 "\n" row1 "\n" row2)))

(fn tabs [tab-list user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (let [n (# tab-list)
          max-ch (accumulate [m 0 _ tab (ipairs tab-list)]
                   (math.max m (# (util.split-lines (or tab.content "")))))]
      (var active 1)
      (var result nil)
      (var term-w (let [(_ c) (term.size)] (or c 80)))
      (term.with-raw
        (fn []
          (var running true)
          (while running
            (set term-w (let [(_ c) (term.size)] (or c 80)))
            (let [bar (render-tab-bar tab-list active opts term-w)
                  bar-lines (util.split-lines bar)
                  content (or (. tab-list active :content) "")
                  content-lines (util.split-lines content)
                  bottom (ansi.style (string.rep "─" term-w) opts.active-fg)
                  total-rows (+ max-ch 4)]
              (each [_ line (ipairs bar-lines)]
                (term.write (.. "\r" line ansi.screen.clear-right "\r\n")))
              (for [i 1 max-ch]
                (let [line (or (. content-lines i) "")]
                  (term.write (.. "\r " line ansi.screen.clear-right "\r\n"))))
              (term.write (.. "\r" bottom ansi.screen.clear-right))
              (term.cursor-up total-rows)
              (let [k (term.read-key)]
                (match k
                  (where (or "left" "h")) (set active (math.max 1 (- active 1)))
                  (where (or "right" "l")) (set active (math.min n (+ active 1)))
                  "\t" (set active (if (= active n) 1 (+ active 1)))
                  (where (or "\r" "\n")) (do (set result active) (set running false))
                  (where (or "q" "\003" "escape")) (set running false)
                  "resize" nil
                  _ (let [d (tonumber k)]
                      (when (and d (>= d 1) (<= d n))
                        (set active d)))))))))
      (for [_ 1 (+ max-ch 4)]
        (term.write (.. "\r" ansi.screen.clear-right "\r\n")))
      (term.cursor-up (+ max-ch 4))
      result)))

{:render-tab-bar render-tab-bar :tabs tabs}
