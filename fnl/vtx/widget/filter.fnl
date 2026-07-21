(local term (require "vtx.term"))

(local ansi (require "vtx.ansi"))

(local util (require "vtx.util"))

(local theme (require "vtx.theme"))

(local default-opts {:alt-screen false
                     :cursor "> "
                     :cursor-fg ansi.fg.cyan
                     :fuzzy true
                     :height 10
                     :match-fg ansi.fg.yellow
                     :multi false
                     :prompt "> "
                     :prompt-fg ansi.fg.cyan
                     :recent []
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

(local list-nav (require "vtx.list-nav"))

(fn filter [items user-opts]
  (let [opts (theme.merge default-opts user-opts)
        nav (list-nav.make-state 0 opts.height)
        fcache (term.make-frame-cache)]
    (var query "")
    (var selected {})
    (var result nil)
    (var matches (filter-items items query opts.fuzzy))
    (var term-w (let [(_ c) (term.size)]
                  (or c 80)))
    (var cached-merged nil)
    (var cached-matches-id nil)
    (fn compute-display []
      (if (and (= query "") (> (# opts.recent) 0))
          (if (= cached-matches-id matches)
              cached-merged
              (let [seen {}
                    merged []]
                (each [_ m (ipairs (filter-items opts.recent "" false))]
                  (tset seen m.item true)
                  (table.insert merged m))
                (each [_ m (ipairs matches)]
                  (when (not (. seen m.item))
                    (table.insert merged m)))
                (set cached-merged merged)
                (set cached-matches-id matches)
                merged))
          matches))
    (fn reset-search [new-query]
      (set query new-query)
      (set matches (filter-items items new-query opts.fuzzy))
      (set nav.cursor 1)
      (set nav.offset 0))
    (term.with-raw (fn []
                     (var running true)
                     (while running
                       (set term-w (let [(_ c) (term.size)]
                                     (or c 80)))
                       (let [display-matches (compute-display)]
                         (list-nav.set-n nav (# display-matches))
                         (list-nav.clamp nav)
                         (term.render-frame fcache (fn [push]
                                                     (let [count-str (if (= query "")
                                                                         ""
                                                                         (ansi.style (.. " " (# matches) "/" (# items)) ansi.dim))]
                                                       (push (.. "\r" (ansi.style opts.prompt opts.prompt-fg) query count-str ansi.screen.clear-right "\r
")))
                                                     (for [row 1 opts.height]
                                                       (let [i (+ nav.offset row)
                                                             m (. display-matches i)]
                                                         (push (.. "\r" (if m
                                                                            (let [is-cursor (= i nav.cursor)
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
                                                     (push (ansi.cursor.up (+ opts.height 1)))
                                                     (push (ansi.cursor.col (+ (ansi.len opts.prompt) (ansi.len query) 1)))))
                         (let [k (term.read-key)]
                           (if (list-nav.handle-key-typable nav k)
                               nil
                               (match k
                                 "\t" (when (and opts.multi (> (# matches) 0))
                                        (let [m (. matches nav.cursor)]
                                          (when m
                                            (if (. selected m.i)
                                                (tset selected m.i nil)
                                                (tset selected m.i true))))
                                        (list-nav.move nav 1))
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
                                                              (let [m (. matches nav.cursor)]
                                                                (set result (when m
                                                                              [m.item]))))
                                                          (set running false))
                                 (where (or "\003" "\027")) (set running false)
                                 (where (or "\b" "\127")) (when (> (# query) 0)
                                                            (reset-search (query:sub 1 (- (# query) 1))))
                                 "\021" (reset-search "")
                                 "resize" (set term-w (let [(_ c) (term.size)]
                                                        (or c 80)))
                                 _ (when (and (= (type k) "string") (= (# k) 1) (>= (string.byte k) 32))
                                     (reset-search (.. query k))))))))) {:alt-screen opts.alt-screen})
    (when (not opts.alt-screen)
      (term.clear-rows (+ opts.height 1)))
    result))

{:filter filter :filter-items filter-items :fuzzy-match fuzzy-match}
