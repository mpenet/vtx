(local term (require "vtx.term"))

(local ansi (require "vtx.ansi"))

(local util (require "vtx.util"))

(local theme (require "vtx.theme"))

(local default-opts {:alt-screen false :height nil :highlight nil :wrap false})

(fn wrap-line [line max-w]
  (if (or (<= max-w 0) (<= (ansi.len line) max-w))
      [line]
      (let [result {}
            slen (# line)]
        (var i 1)
        (var chunk {})
        (var cw 0)
        (while (<= i slen)
          (if (= (line:sub i i) "\027")
              (let [j (line:find "[A-Za-z]" (+ i 1))]
                (if j
                    (do
                      (table.insert chunk (line:sub i j))
                      (set i (+ j 1)))
                    (set i (+ i 1))))
              (let [(cp cl) (ansi.utf8-codepoint line i)
                    w (ansi.codepoint-width cp)]
                (when (and (> cw 0) (> (+ cw w) max-w))
                  (table.insert result (table.concat chunk))
                  (set chunk {})
                  (set cw 0))
                (table.insert chunk (line:sub i (+ i cl -1)))
                (set cw (+ cw w))
                (set i (+ i cl)))))
        (when (> (# chunk) 0)
          (table.insert result (table.concat chunk)))
        (if (= (# result) 0)
            [line]
            result))))

(fn reflow-lines [lines max-w]
  (let [result {}]
    (each [_ line (ipairs lines)]
      (each [_ wrapped (ipairs (wrap-line line max-w))]
        (table.insert result wrapped)))
    result))

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

(fn render-status [offset height dn search-idx search-matches show-line-nums wrap digit-buf]
  (let [last (math.min (+ offset height) dn)
        pct (if (> dn height)
                (.. (math.floor (* 100 (/ last dn))) "%")
                "100%")
        match-info (if (> (# search-matches) 0)
                       (.. " [" search-idx "/" (# search-matches) "]")
                       "")
        ln-hint (if show-line-nums
                    " [ln]"
                    "")
        wrap-hint (if wrap
                      " [wrap]"
                      "")
        digit-hint (if (and digit-buf (> (# digit-buf) 0))
                       (.. " :" digit-buf)
                       "")]
    (.. "\r" (ansi.style (.. "lines " (+ offset 1) "-" last "/" dn " " pct match-info " - q:quit /:search g/G l:ln# w:wrap" ln-hint wrap-hint digit-hint) ansi.reverse) ansi.screen.clear-right)))

(fn pager [text user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (let [lines (util.split-lines text)
          (term-rows _) (term.size)]
      (var height (or opts.height (- (or term-rows 24) 1)))
      (var offset 0)
      (var search-query "")
      (var search-mode false)
      (var search-matches {})
      (var search-idx 1)
      (var prev-at-bottom false)
      (var show-line-nums false)
      (var wrap opts.wrap)
      (var digit-buf "")
      (var term-w 80)
      (var display-n 0)
      (fn jump-to [line-idx]
        (let [max-off (math.max 0 (- display-n height))]
          (set offset (math.max 0 (math.min (- line-idx 1) max-off)))))
      (term.with-raw (fn []
                       (var running true)
                       (while running
                         (let [(tr tc) (term.size)]
                           (set term-w (or tc 80)))
                         (let [dl (if wrap
                                      (reflow-lines lines term-w)
                                      lines)
                               dn (# dl)
                               max-off (math.max 0 (- dn height))]
                           (set display-n dn)
                           (set offset (math.min offset max-off))
                           (when prev-at-bottom
                             (term.cursor-up height)
                             (set prev-at-bottom false))
                           (for [row 1 height]
                             (let [raw-line (or (. dl (+ offset row)) "")
                                   searched (if (> (# search-query) 0)
                                                (highlight-search raw-line search-query)
                                                raw-line)
                                   display (if opts.highlight
                                               (opts.highlight searched)
                                               searched)
                                   prefix (if show-line-nums
                                              (ansi.style (string.format "%4d " (+ offset row)) ansi.dim ansi.fg.white)
                                              "")]
                               (term.write (.. "\r" prefix display ansi.screen.clear-right "\r
"))))
                           (if search-mode
                               (term.write (.. "\r" (ansi.style (.. "/" search-query) ansi.fg.yellow) (ansi.style " " ansi.reverse) ansi.screen.clear-right))
                               (term.write (render-status offset height dn search-idx search-matches show-line-nums wrap digit-buf)))
                           (if search-mode
                               (set prev-at-bottom true)
                               (do
                                 (set prev-at-bottom false)
                                 (term.cursor-up height)))
                           (let [k (term.read-key)]
                             (if search-mode
                                 (match k
                                   (where (or "\r" "\n")) (do
                                                            (set search-mode false)
                                                            (when (> (# search-query) 0)
                                                              (let [dl2 (if wrap
                                                                            (reflow-lines lines term-w)
                                                                            lines)]
                                                                (set search-matches (find-matches dl2 search-query))
                                                                (set search-idx 1)
                                                                (when (> (# search-matches) 0)
                                                                  (jump-to (. search-matches 1))))))
                                   (where (or "\003" "escape")) (do
                                                                  (set search-mode false)
                                                                  (set search-query "")
                                                                  (set search-matches {}))
                                   (where (or "\b" "\127")) (when (> (# search-query) 0)
                                                              (set search-query (search-query:sub 1 (- (# search-query) 1)))
                                                              (let [dl2 (if wrap
                                                                            (reflow-lines lines term-w)
                                                                            lines)]
                                                                (set search-matches (find-matches dl2 search-query))
                                                                (set search-idx 1)))
                                   _ (when (and (= (type k) "string") (= (# k) 1) (>= (string.byte k) 32))
                                       (set search-query (.. search-query k))
                                       (let [dl2 (if wrap
                                                     (reflow-lines lines term-w)
                                                     lines)]
                                         (set search-matches (find-matches dl2 search-query))
                                         (set search-idx 1)
                                         (when (> (# search-matches) 0)
                                           (jump-to (. search-matches 1))))))
                                 (match k
                                   (where (or "up" "k" "\016")) (do
                                                                  (set digit-buf "")
                                                                  (set offset (math.max 0 (- offset 1))))
                                   (where (or "down" "j" "\014")) (do
                                                                    (set digit-buf "")
                                                                    (set offset (math.min max-off (+ offset 1))))
                                   "\006" (do
                                            (set digit-buf "")
                                            (set offset (math.min max-off (+ offset (math.floor (/ height 2))))))
                                   "\002" (do
                                            (set digit-buf "")
                                            (set offset (math.max 0 (- offset (math.floor (/ height 2))))))
                                   "g" (do
                                         (set digit-buf "")
                                         (set offset 0))
                                   "G" (do
                                         (if (> (# digit-buf) 0)
                                             (jump-to (tonumber digit-buf))
                                             (set offset max-off))
                                         (set digit-buf ""))
                                   "l" (do
                                         (set digit-buf "")
                                         (set show-line-nums (not show-line-nums)))
                                   "w" (do
                                         (set digit-buf "")
                                         (set wrap (not wrap))
                                         (when (> (# search-query) 0)
                                           (let [dl2 (if wrap
                                                         (reflow-lines lines term-w)
                                                         lines)]
                                             (set search-matches (find-matches dl2 search-query)))))
                                   "page-up" (do
                                               (set digit-buf "")
                                               (set offset (math.max 0 (- offset height))))
                                   (where (or " " "page-down")) (do
                                                                  (set digit-buf "")
                                                                  (set offset (math.min max-off (+ offset height))))
                                   "/" (do
                                         (set digit-buf "")
                                         (set search-mode true)
                                         (set search-query ""))
                                   "n" (do
                                         (set digit-buf "")
                                         (when (> (# search-matches) 0)
                                           (set search-idx (if (>= search-idx (# search-matches))
                                                               1
                                                               (+ search-idx 1)))
                                           (jump-to (. search-matches search-idx))))
                                   "N" (do
                                         (set digit-buf "")
                                         (when (> (# search-matches) 0)
                                           (set search-idx (if (<= search-idx 1)
                                                               (# search-matches)
                                                               (- search-idx 1)))
                                           (jump-to (. search-matches search-idx))))
                                   "resize" (when (not opts.height)
                                              (let [(tr _) (term.size)]
                                                (set height (- (or tr 24) 1))))
                                   (where (or "q" "\003")) (set running false)
                                   _ (when (and (= (type k) "string") (= (# k) 1) (string.match k "%d"))
                                       (set digit-buf (.. digit-buf k)))))))
                         {:alt-screen opts.alt-screen})))
      (when (not opts.alt-screen)
        (for [_ 1 (+ height 1)]
          (term.write (.. "\r" ansi.screen.clear-right "\r
")))
        (term.cursor-up (+ height 1))))))

{:find-matches find-matches
 :highlight-search highlight-search
 :pager pager
 :reflow-lines reflow-lines
 :render-status render-status
 :wrap-line wrap-line}
