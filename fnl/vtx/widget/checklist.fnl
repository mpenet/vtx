(local term (require "vtx.term"))

(local ansi (require "vtx.ansi"))

(local util (require "vtx.util"))

(local theme (require "vtx.theme"))

(local list-nav (require "vtx.list-nav"))

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
  (let [opts (theme.merge default-opts user-opts)]
    (let [n (# items)
          height (math.min opts.height n)
          nav (list-nav.make-state n height)
          checked {}]
      (each [_ idx (ipairs opts.checked)]
        (when (and (>= idx 1) (<= idx n))
          (tset checked idx true)))
      (var result nil)
      (var term-w 80)
      (let [fcache (term.make-frame-cache)]
        (term.with-raw (fn []
                         (var running true)
                         (while running
                           (set term-w (let [(_ c) (term.size)]
                                         (or c 80)))
                           (list-nav.clamp nav)
                           (term.render-frame fcache (fn [push]
                                                       (list-nav.each-visible nav (fn [_row i _is-cursor]
                                                                                    (push (.. "\r" (if (<= i n)
                                                                                                       (render-item (. items i) i nav.cursor checked opts term-w)
                                                                                                       "") ansi.screen.clear-right "\r
"))))
                                                       (let [nchecked (accumulate [c 0 _ _ (pairs checked)] (+ c 1))]
                                                         (push (.. "\r" (ansi.style (.. nchecked "/" n " · space:toggle · a:all · enter:confirm") ansi.dim) ansi.screen.clear-right)))
                                                       (push (ansi.cursor.up height))))
                           (let [k (term.read-key)]
                             (if (list-nav.handle-key nav k)
                                 nil
                                 (match k
                                   " " (if (. checked nav.cursor)
                                           (tset checked nav.cursor nil)
                                           (tset checked nav.cursor true))
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
                                   (where (or "q" "\003" "escape")) (set running false))))))))
      (term.clear-rows (+ height 1))
      result)))

{:checklist checklist :render-item render-item}
