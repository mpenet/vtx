(local term (require "tiki.term"))

(local ansi (require "tiki.ansi"))

(local util (require "tiki.util"))

(local theme (require "tiki.theme"))

(local default-opts {:checked []
                     :cursor "> "
                     :cursor-fg ansi.fg.cyan
                     :height 10
                     :selected-fg ansi.fg.green
                     :unselected-fg ansi.fg.white})

(fn render-item [item i cursor checked opts term-w]
  (let [is-cursor (= i cursor)
        is-checked (. checked i)
        cursor-width (ansi.len opts.cursor)
        prefix (if is-cursor
                   (ansi.style opts.cursor opts.cursor-fg)
                   (util.string-rep " " cursor-width))
        box (if is-checked
                (ansi.style "[x]" opts.selected-fg)
                (ansi.style "[ ]" opts.unselected-fg))
        max-item-w (- term-w cursor-width 4)
        text (util.trunc item max-item-w)
        styled-text (if is-cursor
                        (ansi.style text ansi.bold opts.selected-fg)
                        is-checked
                        (ansi.style text opts.selected-fg)
                        (ansi.style text opts.unselected-fg))]
    (.. prefix box " " styled-text)))

(fn checklist [items user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (let [n (# items)
          height (math.min opts.height n)
          checked {}]
      (each [_ idx (ipairs opts.checked)]
        (when (and (>= idx 1) (<= idx n))
          (tset checked idx true)))
      (var cursor 1)
      (var offset 0)
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
                                                      (render-item (. items i) i cursor checked opts term-w)
                                                      "") ansi.screen.clear-right "\r
"))))
                         (let [nchecked (accumulate [c 0 _ _ (pairs checked)] (+ c 1))]
                           (term.write (.. "\r" (ansi.style (.. nchecked "/" n " · space:toggle · a:all · enter:confirm") ansi.dim) ansi.screen.clear-right)))
                         (term.cursor-up height)
                         (let [k (term.read-key)]
                           (match k
                             (where (or "up" "k" "\016")) (set cursor (math.max 1 (- cursor 1)))
                             (where (or "down" "j" "\014")) (set cursor (math.min n (+ cursor 1)))
                             "g" (set cursor 1)
                             "G" (set cursor n)
                             " " (if (. checked cursor)
                                     (tset checked cursor nil)
                                     (tset checked cursor true))
                             "a" (if (= (next checked) nil)
                                     (for [i 1 n]
                                       (tset checked i true))
                                     (for [i 1 n]
                                       (tset checked i nil)))
                             (where (or "\r" "\n")) (do
                                                      (let [picks {}]
                                                        (for [i 1 n]
                                                          (when (. checked i)
                                                            (table.insert picks (. items i))))
                                                        (set result picks))
                                                      (set running false))
                             (where (or "q" "\003" "escape")) (set running false))))) nil)
      (for [_ 1 (+ height 1)]
        (term.write (.. "\r" ansi.screen.clear-right "\r
")))
      (term.cursor-up (+ height 1))
      result)))

{:checklist checklist :render-item render-item}
