(local term (require "tiki.term"))

(local ansi (require "tiki.ansi"))

(local util (require "tiki.util"))

(local theme (require "tiki.theme"))

(local default-opts {:alt-screen false
                     :cursor "> "
                     :cursor-fg ansi.fg.cyan
                     :fuzzy true
                     :height 10
                     :match-fg ansi.fg.yellow
                     :multi false
                     :prompt "> "
                     :prompt-fg ansi.fg.cyan
                     :render nil
                     :selected-attr ansi.bold
                     :selected-fg ansi.fg.green
                     :unselected-fg ansi.fg.white})

(fn fuzzy-match [item query]
  (if (= query "")
      []
      (let [positions {}
            item-lower (item:lower)
            q-lower (query:lower)
            qlen (# q-lower)]
        (var qi 1)
        (for [ii 1 (# item-lower) &until (> qi qlen)]
          (when (= (item-lower:sub ii ii) (q-lower:sub qi qi))
            (table.insert positions ii)
            (set qi (+ qi 1))))
        (when (> qi qlen)
          positions))))

(fn highlight [item positions match-fg]
  (if (or (not positions) (= (# positions) 0))
      item
      (let [pos-set {}
            result {}]
        (each [_ p (ipairs positions)]
          (tset pos-set p true))
        (for [i 1 (# item)]
          (let [ch (item:sub i i)]
            (if (. pos-set i)
                (table.insert result (ansi.style ch match-fg ansi.bold))
                (table.insert result ch))))
        (table.concat result))))

(fn filter-items [items query fuzzy]
  (let [results {}]
    (each [i item (ipairs items)]
      (if (= query "")
          (table.insert results {:i i :item item :positions []})
          (let [positions (if fuzzy
                              (fuzzy-match item query)
                              (let [low (item:lower)
                                    start (low:find (query:lower) 1 true)]
                                (when start
                                  (let [p {}]
                                    (for [j start (+ start (# query) -1)]
                                      (table.insert p j))
                                    p))))]
            (when positions
              (table.insert results {:i i :item item :positions positions})))))
    results))

(fn filter [items user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (var query "")
    (var cursor 1)
    (var offset 0)
    (var selected {})
    (var result nil)
    (var matches (filter-items items query opts.fuzzy))
    (var term-w (let [(_ c) (term.size)]
                  (or c 80)))
    (fn clamp-cursor []
      (let [n (# matches)]
        (set cursor (math.max 1 (math.min cursor n)))))
    (term.with-raw (fn []
                     (var running true)
                     (while running
                       (clamp-cursor)
                       (set term-w (let [(_ c) (term.size)]
                                     (or c 80)))
                       (let [n (# matches)
                             height (math.min opts.height n)]
                         (when (and (> n 0) (< cursor (+ offset 1)))
                           (set offset (- cursor 1)))
                         (when (and (> n 0) (> cursor (+ offset height)))
                           (set offset (- cursor height)))
                         (let [count-str (if (= query "")
                                             ""
                                             (ansi.style (.. " " (# matches) "/" (# items)) ansi.dim))]
                           (term.write (.. "\r" (ansi.style opts.prompt opts.prompt-fg) query count-str ansi.screen.clear-right "\r
")))
                         (for [row 1 opts.height]
                           (let [i (+ offset row)
                                 m (. matches i)]
                             (term.write (.. "\r" (if m
                                                      (let [is-cursor (= i cursor)
                                                            is-selected (. selected m.i)
                                                            cursor-width (ansi.len opts.cursor)
                                                            multi-mark (if opts.multi
                                                                           (if is-selected
                                                                               (ansi.style "● " opts.selected-fg)
                                                                               (ansi.style "○ " opts.unselected-fg))
                                                                           "")
                                                            prefix (if is-cursor
                                                                       (ansi.style opts.cursor opts.cursor-fg)
                                                                       (util.string-rep " " cursor-width))
                                                            mark-w (if opts.multi
                                                                       2
                                                                       0)
                                                            max-item-w (- term-w cursor-width mark-w)
                                                            raw-text (util.trunc (if opts.render
                                                                                     (opts.render m.item m.positions)
                                                                                     (highlight m.item m.positions opts.match-fg)) max-item-w)
                                                            text (if is-cursor
                                                                     (ansi.style (.. multi-mark raw-text) opts.selected-attr opts.selected-fg)
                                                                     (.. multi-mark raw-text))]
                                                        (.. prefix text))
                                                      "") ansi.screen.clear-right "\r
"))))
                         (term.cursor-up (+ opts.height 1))
                         (term.cursor-col (+ (ansi.len opts.prompt) (ansi.len query) 1))
                         (let [k (term.read-key)]
                           (match k
                             (where (or "up" "\016")) (set cursor (math.max 1 (- cursor 1)))
                             (where (or "down" "\014")) (set cursor (math.min (# matches) (+ cursor 1)))
                             "\t" (when (and opts.multi (> (# matches) 0))
                                    (let [m (. matches cursor)]
                                      (when m
                                        (if (. selected m.i)
                                            (tset selected m.i nil)
                                            (tset selected m.i true))))
                                    (set cursor (math.min (# matches) (+ cursor 1))))
                             (where (or "\r" "\n")) (do
                                                      (if (and opts.multi (next selected))
                                                          (let [picks {}
                                                                idxs {}]
                                                            (each [orig-i _ (pairs selected)]
                                                              (table.insert idxs orig-i))
                                                            (table.sort idxs)
                                                            (each [_ orig-i (ipairs idxs)]
                                                              (table.insert picks (. items orig-i)))
                                                            (set result picks))
                                                          (let [m (. matches cursor)]
                                                            (set result (when m
                                                                          [m.item]))))
                                                      (set running false))
                             (where (or "\003" "\027")) (set running false)
                             (where (or "\b" "\127")) (when (> (# query) 0)
                                                        (set query (query:sub 1 (- (# query) 1)))
                                                        (set matches (filter-items items query opts.fuzzy))
                                                        (set cursor 1)
                                                        (set offset 0))
                             "\021" (do
                                      (set query "")
                                      (set matches (filter-items items query opts.fuzzy))
                                      (set cursor 1)
                                      (set offset 0))
                             "resize" (set term-w (let [(_ c) (term.size)]
                                                    (or c 80)))
                             _ (when (and (= (type k) "string") (= (# k) 1) (>= (string.byte k) 32))
                                 (set query (.. query k))
                                 (set matches (filter-items items query opts.fuzzy))
                                 (set cursor 1)
                                 (set offset 0))))))) {:alt-screen opts.alt-screen})
    (when (not opts.alt-screen)
      (for [_ 1 (+ opts.height 1)]
        (term.write (.. "\r" ansi.screen.clear-right "\r
")))
      (term.cursor-up (+ opts.height 1)))
    result))

{:filter filter :filter-items filter-items :fuzzy-match fuzzy-match}
