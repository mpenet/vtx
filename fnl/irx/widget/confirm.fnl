(local term (require "irx.term"))

(local ansi (require "irx.ansi"))

(local theme (require "irx.theme"))

(local default-opts {:affirmative "Yes"
                     :default true
                     :negative "No"
                     :prompt-fg ansi.fg.cyan
                     :selected-attr ansi.bold
                     :selected-fg ansi.fg.green
                     :unselected-fg ansi.fg.white})

(fn render [prompt selected opts]
  (let [yes-label opts.affirmative
        no-label opts.negative
        yes-str (if selected
                    (ansi.style yes-label opts.selected-attr opts.selected-fg)
                    (ansi.style yes-label opts.unselected-fg))
        no-str (if (not selected)
                   (ansi.style no-label opts.selected-attr opts.selected-fg)
                   (ansi.style no-label opts.unselected-fg))
        prompt-str (ansi.style prompt opts.prompt-fg)]
    (.. prompt-str "  " yes-str "  " no-str)))

(fn confirm [prompt user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (var selected (if (= opts.default false)
                      false
                      true))
    (var result nil)
    (term.with-raw (fn []
                     (var running true)
                     (while running
                       (term.clear-line)
                       (term.cursor-col 1)
                       (term.write (render prompt selected opts))
                       (let [k (term.read-key)]
                         (match k
                           (where (or "left" "right" "h" "l" "\002" "\006")) (set selected (not selected))
                           (where (or "\r" "\n")) (do
                                                    (set result selected)
                                                    (set running false))
                           "y" (do
                                 (set result true)
                                 (set running false))
                           "n" (do
                                 (set result false)
                                 (set running false))
                           (where (or "\003" "escape")) (do
                                                          (set running false)))))))
    (term.writeln "")
    result))

{:confirm confirm :render render}
