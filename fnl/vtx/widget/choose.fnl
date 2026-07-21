(local term (require "vtx.term"))

(local ansi (require "vtx.ansi"))

(local util (require "vtx.util"))

(local theme (require "vtx.theme"))

(local list-nav (require "vtx.list-nav"))

(local default-opts {:alt-screen false
                     :cursor "> "
                     :cursor-fg ansi.fg.cyan
                     :height 10
                     :multi false
                     :search false
                     :selected-attr ansi.bold
                     :selected-fg ansi.fg.green
                     :unselected-fg ansi.fg.white})

(fn clamp [v lo hi]
  (math.max lo (math.min hi v)))

(fn search-items [items query]
  (if (= query "")
      {}
      (let [results {}
            low-q (query:lower)]
        (each [i item (ipairs items)]
          (when (: (item:lower) "find" low-q 1 true)
            (table.insert results i)))
        results)))

(fn highlight-match [item query]
  (if (= query "")
      item
      (let [low-item (item:lower)
            low-q (query:lower)
            start (low-item:find low-q 1 true)]
        (if (not start)
            item
            (let [qlen (# query)]
              (.. (item:sub 1 (- start 1)) (ansi.style (item:sub start (+ start qlen -1)) ansi.fg.yellow ansi.bold) (item:sub (+ start qlen))))))))

(fn render-item [item i cursor selected-set opts term-w search-query]
  (let [is-cursor (= i cursor)
        is-selected (. selected-set i)
        cursor-width (ansi.len opts.cursor)
        multi-mark (if opts.multi
                       (if is-selected
                           (ansi.style "● " opts.selected-fg)
                           (ansi.style "○ " opts.unselected-fg))
                       "")
        prefix (if is-cursor
                   (ansi.style opts.cursor opts.cursor-fg)
                   (util.string-rep " " cursor-width))
        max-item-w (- term-w cursor-width (if opts.multi
                                              2
                                              0))
        display-item (util.trunc (highlight-match item search-query) max-item-w)
        text (if is-cursor
                 (ansi.style (.. multi-mark display-item) opts.selected-attr opts.selected-fg)
                 is-selected
                 (ansi.style (.. multi-mark display-item) opts.selected-fg)
                 (.. multi-mark (ansi.style display-item opts.unselected-fg)))]
    (.. prefix text)))

(fn choose [items user-opts]
  (let [opts (theme.merge default-opts user-opts)]
    (let [n (# items)
          height (math.min opts.height n)
          nav (list-nav.make-state n height)
          fcache (term.make-frame-cache)]
      (var selected {})
      (var result nil)
      (var term-w 80)
      (var search-mode false)
      (var search-query "")
      (var search-matches {})
      (var search-idx 1)
      (term.with-raw (fn []
                       (var running true)
                       (while running
                         (set term-w (let [(_ c) (term.size)]
                                       (or c 80)))
                         (list-nav.clamp nav)
                         (term.render-frame fcache (fn [push]
                                                     (list-nav.each-visible nav (fn [_row i _is-cursor]
                                                                                  (push (.. "\r" (if (<= i n)
                                                                                                     (render-item (. items i) i nav.cursor selected opts term-w search-query)
                                                                                                     "") ansi.screen.clear-right "\r
"))))
                                                     (when opts.search
                                                       (if search-mode
                                                           (push (.. "\r" (ansi.style (.. "/" search-query) ansi.fg.yellow) (ansi.style " " ansi.reverse) ansi.screen.clear-right))
                                                           (if (> (# search-query) 0)
                                                               (let [nm (# search-matches)]
                                                                 (push (.. "\r" (ansi.style (.. "/" search-query " (" nm " match" (if (= nm 1)
                                                                                                                                      ""
                                                                                                                                      "es") ") - n/N cycle") ansi.dim) ansi.screen.clear-right)))
                                                               (push (.. "\r" (ansi.style "/ to search" ansi.dim) ansi.screen.clear-right)))))
                                                     (push (ansi.cursor.up height))))
                         (let [k (term.read-key)]
                           (if search-mode
                               (match k
                                 (where (or "\r" "\n" "escape")) (set search-mode false)
                                 "\003" (do
                                          (set search-mode false)
                                          (set search-query "")
                                          (set search-matches {}))
                                 (where (or "\b" "\127")) (when (> (# search-query) 0)
                                                            (set search-query (search-query:sub 1 (- (# search-query) 1)))
                                                            (set search-matches (search-items items search-query))
                                                            (set search-idx 1)
                                                            (when (> (# search-matches) 0)
                                                              (set nav.cursor (. search-matches 1))))
                                 _ (when (and (= (type k) "string") (= (# k) 1) (>= (string.byte k) 32))
                                     (set search-query (.. search-query k))
                                     (set search-matches (search-items items search-query))
                                     (set search-idx 1)
                                     (when (> (# search-matches) 0)
                                       (set nav.cursor (. search-matches 1)))))
                               (if (list-nav.handle-key nav k)
                                   nil
                                   (match k
                                     "/" (when opts.search
                                           (set search-mode true)
                                           (set search-query ""))
                                     "n" (when (> (# search-matches) 0)
                                           (set search-idx (if (>= search-idx (# search-matches))
                                                               1
                                                               (+ search-idx 1)))
                                           (set nav.cursor (. search-matches search-idx)))
                                     "N" (when (> (# search-matches) 0)
                                           (set search-idx (if (<= search-idx 1)
                                                               (# search-matches)
                                                               (- search-idx 1)))
                                           (set nav.cursor (. search-matches search-idx)))
                                     " " (when opts.multi
                                           (if (. selected nav.cursor)
                                               (tset selected nav.cursor nil)
                                               (tset selected nav.cursor true)))
                                     (where (or "\r" "\n")) (do
                                                              (if opts.multi
                                                                  (let [picks {}]
                                                                    (for [i 1 n]
                                                                      (when (. selected i)
                                                                        (table.insert picks (. items i))))
                                                                    (set result (if (= (# picks) 0)
                                                                                    [(. items nav.cursor)]
                                                                                    picks)))
                                                                  (set result (. items nav.cursor)))
                                                              (set running false))
                                     "resize" (set term-w (let [(_ c) (term.size)]
                                                            (or c 80)))
                                     (where (or "q" "\003" "escape")) (set running false))))))) {:alt-screen opts.alt-screen})
      (when (not opts.alt-screen)
        (let [clear-rows (if opts.search
                             (+ height 1)
                             height)]
          (term.clear-rows clear-rows)))
      result)))

{:choose choose :highlight-match highlight-match :search-items search-items}
