(local term (require "tiki.term"))

(local ansi (require "tiki.ansi"))

(local util (require "tiki.util"))

(local theme (require "tiki.theme"))

(local default-opts {:cursor "> "
                     :cursor-fg ansi.fg.cyan
                     :height 10
                     :multi false
                     :selected-attr ansi.bold
                     :selected-fg ansi.fg.green
                     :unselected-fg ansi.fg.white})

(fn clamp [v lo hi]
  (math.max lo (math.min hi v)))

(fn render-item [item i cursor selected-set opts term-w]
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
        display-item (util.trunc item max-item-w)
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
                                                      (render-item (. items i) i cursor selected opts term-w)
                                                      "") ansi.screen.clear-right "\r
"))))
                         (term.cursor-up height)
                         (let [k (term.read-key)]
                           (match k
                             (where (or "up" "k" "\016")) (set cursor (clamp (- cursor 1) 1 n))
                             (where (or "down" "j" "\014")) (set cursor (clamp (+ cursor 1) 1 n))
                             "\006" (set cursor (clamp (+ cursor (math.floor (/ height 2))) 1 n))
                             "\002" (set cursor (clamp (- cursor (math.floor (/ height 2))) 1 n))
                             "g" (set cursor 1)
                             "G" (set cursor n)
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
                             (where (or "q" "\003")) (set running false))))))
      (for [_ 1 height]
        (term.write (.. "\r" ansi.screen.clear-right "\r
")))
      (term.cursor-up height)
      result)))

{:choose choose}
