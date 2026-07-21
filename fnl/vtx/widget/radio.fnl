(local term (require "vtx.term"))

(local ansi (require "vtx.ansi"))

(local theme (require "vtx.theme"))

(local list-nav (require "vtx.list-nav"))

(local keymap (require "vtx.keymap"))

(local default-opts {:cursor-fg ansi.fg.cyan
                     :height nil
                     :keymap nil
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
  (let [opts (theme.merge default-opts user-opts)]
    (let [n (# items)
          height (math.min (or opts.height n) n)
          nav (list-nav.make-state n height)
          fcache (term.make-frame-cache)]
      (var selected nil)
      (var result nil)
      (when opts.value
        (each [i item (ipairs items) &until selected]
          (when (= item opts.value)
            (set selected i))))
      (term.with-raw (fn []
                       (var running true)
                       (while running
                         (list-nav.clamp nav)
                         (let [rows-drawn (+ (if opts.prompt
                                                 1
                                                 0) height)]
                           (term.render-frame fcache (fn [push]
                                                       (when opts.prompt
                                                         (push (.. "\r" (ansi.style opts.prompt ansi.bold) ansi.screen.clear-right "\r
")))
                                                       (list-nav.each-visible nav (fn [_row i _is-cursor]
                                                                                    (push (.. "\r" (if (<= i n)
                                                                                                       (render-item (. items i) i nav.cursor selected opts)
                                                                                                       "") ansi.screen.clear-right "\r
"))))
                                                       (push (ansi.cursor.up rows-drawn)))))
                         (let [km (keymap.merge keymap.nav-defaults opts.keymap)
                               k (term.read-key)
                               action (keymap.lookup km k)]
                           (match action
                             "up" (list-nav.move nav -1)
                             "down" (list-nav.move nav 1)
                             "top" (list-nav.goto nav 1)
                             "bottom" (list-nav.goto nav n)
                             "page-up" (list-nav.page-up nav)
                             "page-down" (list-nav.page-down nav)
                             "toggle" (set selected nav.cursor)
                             "confirm" (do
                                         (set result (. items (or selected nav.cursor)))
                                         (set running false))
                             "cancel" (set running false)
                             _ nil)))))
      (let [total-rows (+ (if opts.prompt
                              1
                              0) height)]
        (term.clear-rows total-rows))
      result)))

{:radio radio :render-item render-item}
