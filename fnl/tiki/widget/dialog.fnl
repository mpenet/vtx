(local ansi (require "tiki.ansi"))

(local style-m (require "tiki.widget.style"))

(local term (require "tiki.term"))

(local theme (require "tiki.theme"))

(local util (require "tiki.util"))

(local default-opts
  {:active-fg ansi.fg.cyan
   :border "rounded"
   :button-sep "  "
   :fg ansi.fg.white
   :padding 1
   :width 40})

(fn render-buttons [buttons active opts]
  (let [parts (icollect [i label (ipairs buttons)]
                (if (= i active)
                    (ansi.style (.. "[ " label " ]") ansi.bold opts.active-fg)
                    (ansi.style (.. "  " label "  ") opts.fg)))]
    (table.concat parts opts.button-sep)))

(fn dialog [message buttons user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (let [n (# buttons)
          nl (string.char 10)]
      (var active 1)
      (var result nil)
      (term.with-raw
        (fn []
          (var running true)
          (while running
            (let [content (.. message nl nl (render-buttons buttons active opts))
                  box (style-m.style content {:border opts.border
                                              :fg opts.fg
                                              :padding opts.padding
                                              :width opts.width})
                  lines (util.split-lines box)
                  h (# lines)]
              (each [_ line (ipairs lines)]
                (term.write (.. "\r" line ansi.screen.clear-right "\r\n")))
              (term.cursor-up h)
              (let [k (term.read-key)]
                (match k
                  (where (or "left" "h")) (set active (math.max 1 (- active 1)))
                  (where (or "right" "l")) (set active (math.min n (+ active 1)))
                  "\t" (set active (if (= active n) 1 (+ active 1)))
                  (where (or "\r" "\n")) (do (set result active) (set running false))
                  (where (or "q" "\003" "escape")) (set running false)
                  "resize" nil))))))
      (let [content (.. message nl nl (render-buttons buttons active opts))
            box (style-m.style content {:border opts.border
                                        :fg opts.fg
                                        :padding opts.padding
                                        :width opts.width})
            h (# (util.split-lines box))]
        (for [_ 1 h]
          (term.write (.. "\r" ansi.screen.clear-right "\r\n")))
        (term.cursor-up h))
      result)))

{:dialog dialog :render-buttons render-buttons}
