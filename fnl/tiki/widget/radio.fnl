(local term (require "tiki.term"))

(local ansi (require "tiki.ansi"))

(local theme (require "tiki.theme"))

(local default-opts {:cursor-fg ansi.fg.cyan
                     :height nil
                     :prompt nil
                     :selected-fg ansi.fg.green
                     :unselected-fg ansi.fg.white
                     :value nil})

(fn render-item [item i cursor selected-i opts]
  (let [is-cursor (= i cursor)
        is-selected (= i selected-i)
        bullet (if is-selected
                   (ansi.style "●" opts.selected-fg)
                   (ansi.style "○" opts.unselected-fg))
        text (if is-cursor
                 (ansi.style item ansi.bold opts.cursor-fg)
                 is-selected
                 (ansi.style item opts.selected-fg)
                 (ansi.style item opts.unselected-fg))]
    (.. bullet " " text)))

(fn radio [items user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (let [n (# items)
          height (math.min (or opts.height n) n)]
      (var cursor 1)
      (var offset 0)
      (var selected nil)
      (var result nil)
      (when opts.value
        (each [i item (ipairs items) &until selected]
          (when (= item opts.value)
            (set selected i))))
      (term.with-raw (fn []
                       (var running true)
                       (while running
                         (when (< cursor (+ offset 1))
                           (set offset (- cursor 1)))
                         (when (> cursor (+ offset height))
                           (set offset (- cursor height)))
                         (when opts.prompt
                           (term.write (.. "\r" (ansi.style opts.prompt ansi.bold) ansi.screen.clear-right "\r\n")))
                         (for [row 1 height]
                           (let [i (+ offset row)]
                             (term.write (.. "\r" (if (<= i n)
                                                      (render-item (. items i) i cursor selected opts)
                                                      "") ansi.screen.clear-right "\r\n"))))
                         (let [rows-drawn (+ (if opts.prompt 1 0) height)]
                           (term.cursor-up rows-drawn))
                         (let [k (term.read-key)]
                           (match k
                             (where (or "up" "k" "\016")) (set cursor (math.max 1 (- cursor 1)))
                             (where (or "down" "j" "\014")) (set cursor (math.min n (+ cursor 1)))
                             "g" (set cursor 1)
                             "G" (set cursor n)
                             " " (set selected cursor)
                             (where (or "\r" "\n")) (do
                                                      (set result (. items (or selected cursor)))
                                                      (set running false))
                             (where (or "q" "\003" "escape")) (set running false)
                             "resize" nil)))))
      (let [total-rows (+ (if opts.prompt 1 0) height)]
        (for [_ 1 total-rows]
          (term.write (.. "\r" ansi.screen.clear-right "\r\n")))
        (term.cursor-up total-rows))
      result)))

{:radio radio :render-item render-item}
