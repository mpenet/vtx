(local ansi (require "irx.ansi"))

(local term (require "irx.term"))

(local theme (require "irx.theme"))

(local util (require "irx.util"))

(local default-opts
  {:active-fg ansi.fg.cyan
   :inactive-fg ansi.dim
   :separator "  "})

(fn render-tab-bar [tab-list active-i opts]
  (let [parts (icollect [i tab (ipairs tab-list)]
                (if (= i active-i)
                    (ansi.style (.. "[ " tab.label " ]") ansi.bold opts.active-fg)
                    (ansi.style tab.label opts.inactive-fg)))]
    (table.concat parts opts.separator)))

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
      (term.with-raw
        (fn []
          (var running true)
          (while running
            (let [tab-bar (render-tab-bar tab-list active opts)
                  content (or (. tab-list active :content) "")
                  content-lines (util.split-lines content)
                  total-rows (+ 1 max-ch)]
              (term.write (.. "\r" tab-bar ansi.screen.clear-right "\r\n"))
              (for [i 1 max-ch]
                (let [line (or (. content-lines i) "")]
                  (term.write (.. "\r" line ansi.screen.clear-right "\r\n"))))
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
      (for [_ 1 (+ 1 max-ch)]
        (term.write (.. "\r" ansi.screen.clear-right "\r\n")))
      (term.cursor-up (+ 1 max-ch))
      result)))

{:render-tab-bar render-tab-bar :tabs tabs}
