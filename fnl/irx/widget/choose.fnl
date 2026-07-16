(local term (require "irx.term"))

(local ansi (require "irx.ansi"))

(local util (require "irx.util"))

(local theme (require "irx.theme"))

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
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (let [n (# items)
          height (math.min opts.height n)]
      (var cursor 1)
      (var offset 0)
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
                         (when (< cursor (+ offset 1))
                           (set offset (- cursor 1)))
                         (when (> cursor (+ offset height))
                           (set offset (- cursor height)))
                         (for [row 1 height]
                           (let [i (+ offset row)]
                             (term.write (.. "\r" (if (<= i n)
                                                      (render-item (. items i) i cursor selected opts term-w search-query)
                                                      "") ansi.screen.clear-right "\r
"))))
                         (when opts.search
                           (if search-mode
                               (term.write (.. "\r" (ansi.style (.. "/" search-query) ansi.fg.yellow) (ansi.style " " ansi.reverse) ansi.screen.clear-right))
                               (if (> (# search-query) 0)
                                   (let [nm (# search-matches)]
                                     (term.write (.. "\r" (ansi.style (.. "/" search-query " (" nm " match" (if (= nm 1)
                                                                                                                ""
                                                                                                                "es") ") - n/N cycle") ansi.dim) ansi.screen.clear-right)))
                                   (term.write (.. "\r" (ansi.style "/ to search" ansi.dim) ansi.screen.clear-right)))))
                         (term.cursor-up height)
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
                                                              (set cursor (. search-matches 1))))
                                 _ (when (and (= (type k) "string") (= (# k) 1) (>= (string.byte k) 32))
                                     (set search-query (.. search-query k))
                                     (set search-matches (search-items items search-query))
                                     (set search-idx 1)
                                     (when (> (# search-matches) 0)
                                       (set cursor (. search-matches 1)))))
                               (match k
                                 (where (or "up" "k" "\016")) (set cursor (clamp (- cursor 1) 1 n))
                                 (where (or "down" "j" "\014")) (set cursor (clamp (+ cursor 1) 1 n))
                                 "\006" (set cursor (clamp (+ cursor (math.floor (/ height 2))) 1 n))
                                 "\002" (set cursor (clamp (- cursor (math.floor (/ height 2))) 1 n))
                                 "g" (set cursor 1)
                                 "G" (set cursor n)
                                 "/" (when opts.search
                                       (set search-mode true)
                                       (set search-query ""))
                                 "n" (when (> (# search-matches) 0)
                                       (set search-idx (if (>= search-idx (# search-matches))
                                                           1
                                                           (+ search-idx 1)))
                                       (set cursor (. search-matches search-idx)))
                                 "N" (when (> (# search-matches) 0)
                                       (set search-idx (if (<= search-idx 1)
                                                           (# search-matches)
                                                           (- search-idx 1)))
                                       (set cursor (. search-matches search-idx)))
                                 " " (when opts.multi
                                       (if (. selected cursor)
                                           (tset selected cursor nil)
                                           (tset selected cursor true)))
                                 (where (or "\r" "\n")) (do
                                                          (if opts.multi
                                                              (let [picks {}]
                                                                (for [i 1 n]
                                                                  (when (. selected i)
                                                                    (table.insert picks (. items i))))
                                                                (set result (if (= (# picks) 0)
                                                                                [(. items cursor)]
                                                                                picks)))
                                                              (set result (. items cursor)))
                                                          (set running false))
                                 "resize" (set term-w (let [(_ c) (term.size)]
                                                        (or c 80)))
                                 (where (or "q" "\003" "escape")) (set running false)))))) {:alt-screen opts.alt-screen})
      (when (not opts.alt-screen)
        (let [clear-rows (if opts.search
                             (+ height 1)
                             height)]
          (for [_ 1 clear-rows]
            (term.write (.. "\r" ansi.screen.clear-right "\r
")))
          (term.cursor-up clear-rows)))
      result)))

{:choose choose :highlight-match highlight-match :search-items search-items}
