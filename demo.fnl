(local fennel (require "fennel"))

(set fennel.path (.. "fnl/?.fnl;fnl/?/init.fnl;" fennel.path))

(local tiki (require "tiki"))

(local ansi tiki.ansi)

(fn section [title]
  (print (.. "\n" (ansi.style (.. "── " title " ──") ansi.bold ansi.fg.cyan))))

(fn show [label val]
  (let [display (if (= val nil)
                    (ansi.style "nil (aborted)" ansi.fg.yellow)
                    (= (type val) "table")
                    (if (= (next val) nil)
                        "{}"
                        (let [n (# val)]
                          (if (> n 0)
                              (.. "[" (table.concat (icollect [_ v (ipairs val)] (tostring v)) ", ") "]")
                              (let [parts {}]
                                (each [k v (pairs val)]
                                  (table.insert parts (.. (tostring k) "=" (tostring v))))
                                (.. "{" (table.concat parts ", ") "}")))))
                    (tostring val))]
    (print (.. (ansi.style (.. label ": ") ansi.dim ansi.fg.white) display))))

(section "style — boxes and text decoration")

(print (tiki.style "No border · bold cyan" {:bold true :fg ansi.fg.cyan}))

(print (tiki.style "Rounded border · padding 1" {:border "rounded" :padding 1}))

(print (tiki.style "Double · bold · green · centered" {:align "center"
                                                          :bold true
                                                          :border "double"
                                                          :fg ansi.fg.green
                                                          :padding {:bottom 0 :left 3 :right 3 :top 0}
                                                          :width 36}))

(print (tiki.style "Thick · italic · magenta · margin" {:border "thick"
                                                           :fg ansi.fg.magenta
                                                           :italic true
                                                           :margin {:bottom 0 :left 4 :right 0 :top 0}
                                                           :padding 1}))

(print (tiki.style "Multi-line
right-aligned
with border" {:align "right"
              :border "normal"
              :fg ansi.fg.yellow
              :padding {:bottom 0 :left 2 :right 2 :top 0}
              :width 30}))

(section "confirm — yes/no prompt")

(let [ans (tiki.confirm "Do you want to continue?")]
  (show "confirm" ans))

(section "input — single-line text (with placeholder)")

(let [name (tiki.input {:placeholder "e.g. Ada Lovelace"
                        :prompt "Your name: "
                        :prompt-fg ansi.fg.magenta})]
  (show "input" name))

(section "write — multi-line editor")

(let [text (tiki.write {:header "Write something (ctrl-d to submit):" :height 5 :prompt "  "})]
  (show "write" (when text
                  (let [lines (icollect [l
                                         (text:gmatch "[^
                                                        ]+")] l)]
                    (.. (# lines) " line(s), " (# text) " char(s)")))))

(section "choose — pick one from list")

(let [langs ["Fennel" "Clojure" "Haskell" "Rust" "Go" "Python" "TypeScript" "Lua"]
      pick (tiki.choose langs {:height 5})]
  (show "choose" pick))

(section "choose — multi-select (space to toggle)")

(let [features ["Colors"
                "Borders"
                "Spinner"
                "Input"
                "Multi-line"
                "Fuzzy filter"
                "Table"
                "Pager"]
      picks (tiki.choose features {:height 6 :multi true})]
  (show "choose multi" picks))

(section "filter — fuzzy search (single)")

(let [files ["fnl/tiki/ansi.fnl"
             "fnl/tiki/term.fnl"
             "fnl/tiki/posix.fnl"
             "fnl/tiki/util.fnl"
             "fnl/tiki/widget/style.fnl"
             "fnl/tiki/widget/confirm.fnl"
             "fnl/tiki/widget/input.fnl"
             "fnl/tiki/widget/write.fnl"
             "fnl/tiki/widget/choose.fnl"
             "fnl/tiki/widget/filter.fnl"
             "fnl/tiki/widget/spin.fnl"
             "fnl/tiki/widget/password.fnl"
             "fnl/tiki/widget/progress.fnl"
             "fnl/tiki/widget/pager.fnl"
             "fnl/tiki/widget/form.fnl"
             "fnl/tiki/widget/table.fnl"]
      pick (tiki.filter files {:height 7})]
  (show "filter" pick))

(section "filter — multi-select (tab to toggle)")

(let [tags ["bug" "feature" "docs" "refactor" "test" "perf" "breaking" "wontfix"]
      picks (tiki.filter tags {:height 6 :multi true})]
  (show "filter multi" picks))

(section "spin — animated spinner")

(let [result (tiki.spin (fn []
                          (for [_ 1 8]
                            (coroutine.yield)
                            (let [t (os.clock)]
                              (while (< (os.clock) (+ t 0.1)))))
                          "done!") {:spinner "dots" :title "Working..."})]
  (show "spin" result))

(section "password — masked input")

(let [pw (tiki.password {:prompt "Password: "})]
  (show "password length" (when pw
                            (tostring (# pw)))))

(section "password — with confirm")

(let [pw (tiki.password {:confirm true :confirm-prompt "Confirm password: " :prompt "New password: "})]
  (show "password confirmed" (when pw
                               (tostring (# pw)))))

(section "progress — deterministic bar")

(tiki.progress (fn [update]
                 (for [i 1 20]
                   (update i 20)
                   (let [t (os.clock)]
                     (while (< (os.clock) (+ t 0.05)))))) {:title "Loading..." :width 40})

(section "progress — indeterminate (bouncing)")

(tiki.progress (fn [update]
                 (for [i 1 40]
                   (update)
                   (let [t (os.clock)]
                     (while (< (os.clock) (+ t 0.04)))))) {:indeterminate true :title "Fetching..." :width 40})

(section "pager — scrollable text viewer (/ to search, q to quit)")

(let [lines {}]
  (for [i 1 60]
    (table.insert lines (.. "Line " i ": The quick brown fox jumps over the lazy dog.")))
  (tiki.pager (table.concat lines "\n") {:height 10}))

(section "themes — pick one to apply for the rest of the demo")

(let [theme-names (icollect [k _ (pairs tiki.themes)] k)]
  (table.sort theme-names)
  (let [pick (tiki.filter theme-names {:height 6 :prompt "Theme: "})]
    (when (and pick (. pick 1))
      (tiki.set-theme (. pick 1))
      (print (ansi.style (.. "Theme set: " (. pick 1)) ansi.dim)))))

(section "tbl — interactive table")

(let [headers ["Name" "Lang" "Stars"]
      rows [["Fennel" "Lua" "2.1k"]
            ["Janet" "C" "3.4k"]
            ["Hy" "Python" "4.8k"]
            ["Wisp" "JS" "0.9k"]
            ["Carp" "C" "1.5k"]]
      row (tiki.tbl headers rows {:height 6})]
  (show "tbl selected" row))

(section "form — sequential field collection")

(let [result (tiki.form [{:key "name"
                          :label "Full name"
                          :opts {:placeholder "Ada Lovelace"}
                          :type "input"}
                         {:key "email"
                          :label "Email"
                          :opts {:placeholder "ada@example.com"}
                          :type "input"}
                         {:key "secret"
                          :label "Password"
                          :opts {:prompt "Password: "}
                          :type "password"}
                         {:key "ok" :label "Submit the form?" :type "confirm"}])]
  (show "form" result))

(print (.. "\n" (tiki.style "All done!" {:bold true :border "rounded" :fg ansi.fg.green :padding 1})))
