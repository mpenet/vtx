(local term (require "tiki.term"))

(local ansi (require "tiki.ansi"))

(local util (require "tiki.util"))

(local default-opts {:height nil})

(fn highlight-search [line query]
  (if (= query "")
      line
      (let [low-line (line:lower)
            low-q (query:lower)
            qlen (# low-q)
            result {}]
        (var i 1)
        (while (<= i (# line))
          (let [s (low-line:find low-q i true)]
            (if s
                (do
                  (when (> s i)
                    (table.insert result (line:sub i (- s 1))))
                  (table.insert result (ansi.style (line:sub s (+ s qlen -1)) ansi.fg.yellow ansi.bold))
                  (set i (+ s qlen)))
                (do
                  (table.insert result (line:sub i))
                  (set i (+ (# line) 1))))))
        (table.concat result))))

(fn find-matches [lines query]
  (if (= query "")
      {}
      (let [results {}
            low (query:lower)]
        (each [i line (ipairs lines)]
          (let [low-line (line:lower)]
            (when (low-line:find low 1 true)
              (table.insert results i))))
        results)))

(fn render-status [offset height n search-idx search-matches show-line-nums]
  (let [last (math.min (+ offset height) n)
        pct (if (> n height)
                (.. (math.floor (* 100 (/ last n))) "%")
                "100%")
        match-info (if (> (# search-matches) 0)
                       (.. " [" search-idx "/" (# search-matches) "]")
                       "")
        ln-hint (if show-line-nums
                    " [ln]"
                    "")]
    (.. "\r" (ansi.style (.. "lines " (+ offset 1) "-" last "/" n " " pct match-info " - q quit - / search - g/G - l line#" ln-hint) ansi.reverse) ansi.screen.clear-right)))

(fn pager [text user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (let [lines (util.split-lines text)
          n (# lines)
          (term-rows _) (term.size)
          height (or opts.height (- (or term-rows 24) 1))]
      (var offset 0)
      (var search-query "")
      (var search-mode false)
      (var search-matches {})
      (var search-idx 1)
      (var prev-at-bottom false)
      (var show-line-nums false)
      (fn jump-to [line-idx]
        (let [max-off (math.max 0 (- n height))]
          (set offset (math.max 0 (math.min (- line-idx 1) max-off)))))
      (term.with-raw (fn []
                       (var running true)
                       (while running
                         (when prev-at-bottom
                           (term.cursor-up height)
                           (set prev-at-bottom false))
                         (for [row 1 height]
                           (let [line (or (. lines (+ offset row)) "")
                                 display (if (> (# search-query) 0)
                                             (highlight-search line search-query)
                                             line)
                                 prefix (if show-line-nums
                                            (ansi.style (string.format "%4d " (+ offset row)) ansi.dim ansi.fg.white)
                                            "")]
                             (term.write (.. "\r" prefix display ansi.screen.clear-right "\r
"))))
                         (if search-mode
                             (term.write (.. "\r" (ansi.style (.. "/" search-query) ansi.fg.yellow) (ansi.style " " ansi.reverse) ansi.screen.clear-right))
                             (term.write (render-status offset height n search-idx search-matches show-line-nums)))
                         (if search-mode
                             (set prev-at-bottom true)
                             (do
                               (set prev-at-bottom false)
                               (term.cursor-up height)))
                         (let [k (term.read-key)
                               max-off (math.max 0 (- n height))]
                           (if search-mode
                               (match k
                                 (where (or "\r" "\n")) (do
                                                          (set search-mode false)
                                                          (when (> (# search-query) 0)
                                                            (set search-matches (find-matches lines search-query))
                                                            (set search-idx 1)
                                                            (when (> (# search-matches) 0)
                                                              (jump-to (. search-matches 1)))))
                                 (where (or "\003" "escape")) (do
                                                                (set search-mode false)
                                                                (set search-query "")
                                                                (set search-matches {}))
                                 (where (or "\b" "\127")) (when (> (# search-query) 0)
                                                            (set search-query (search-query:sub 1 (- (# search-query) 1)))
                                                            (set search-matches (find-matches lines search-query))
                                                            (set search-idx 1))
                                 _ (when (and (= (type k) "string") (= (# k) 1) (>= (string.byte k) 32))
                                     (set search-query (.. search-query k))
                                     (set search-matches (find-matches lines search-query))
                                     (set search-idx 1)
                                     (when (> (# search-matches) 0)
                                       (jump-to (. search-matches 1)))))
                               (match k
                                 (where (or "up" "k" "\016")) (set offset (math.max 0 (- offset 1)))
                                 (where (or "down" "j" " " "\014")) (set offset (math.min max-off (+ offset 1)))
                                 "\006" (set offset (math.min max-off (+ offset (math.floor (/ height 2)))))
                                 "\002" (set offset (math.max 0 (- offset (math.floor (/ height 2)))))
                                 "g" (set offset 0)
                                 "G" (set offset max-off)
                                 "l" (set show-line-nums (not show-line-nums))
                                 "page-up" (set offset (math.max 0 (- offset height)))
                                 "page-down" (set offset (math.min max-off (+ offset height)))
                                 "/" (do
                                       (set search-mode true)
                                       (set search-query ""))
                                 "n" (when (> (# search-matches) 0)
                                       (set search-idx (if (>= search-idx (# search-matches))
                                                           1
                                                           (+ search-idx 1)))
                                       (jump-to (. search-matches search-idx)))
                                 "N" (when (> (# search-matches) 0)
                                       (set search-idx (if (<= search-idx 1)
                                                           (# search-matches)
                                                           (- search-idx 1)))
                                       (jump-to (. search-matches search-idx)))
                                 (where (or "q" "\003")) (set running false)))))))
      (for [_ 1 (+ height 1)]
        (term.write (.. "\r" ansi.screen.clear-right "\r
")))
      (term.cursor-up (+ height 1)))))

{:find-matches find-matches :highlight-search highlight-search :pager pager}
