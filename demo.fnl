(local fennel (require "fennel"))

(set fennel.path (.. "fnl/?.fnl;fnl/?/init.fnl;" fennel.path))

(local vtx (require "vtx"))

(local ansi vtx.ansi)

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

(fn busy [secs]
  (let [t (os.clock)]
    (while (< (os.clock) (+ t secs)))))

(section "style — boxes and text decoration")

(print (vtx.style "No border · bold cyan" {:bold true :fg ansi.fg.cyan}))

(print (vtx.style "Rounded border · padding 1" {:border "rounded" :padding 1}))

(print (vtx.style "Double · bold · green · centered" {:align "center"
                                                         :bold true
                                                         :border "double"
                                                         :fg ansi.fg.green
                                                         :padding {:bottom 0 :left 3 :right 3 :top 0}
                                                         :width 36}))

(print (vtx.style "Thick · italic · magenta · margin" {:border "thick"
                                                          :fg ansi.fg.magenta
                                                          :italic true
                                                          :margin {:bottom 0 :left 4 :right 0 :top 0}
                                                          :padding 1}))

(print (vtx.style "Multi-line
right-aligned
with border" {:align "right"
              :border "normal"
              :fg ansi.fg.yellow
              :padding {:bottom 0 :left 2 :right 2 :top 0}
              :width 30}))

(section "hbox — side-by-side panels")

(let [a (vtx.style "Left
panel
three lines" {:border "rounded" :fg ansi.fg.cyan :padding 1})
      b (vtx.style "Center
panel" {:border "rounded" :fg ansi.fg.green :padding 1})
      c (vtx.style "Right" {:border "rounded" :fg ansi.fg.magenta :padding 1})]
  (print (vtx.hbox [a b c] {:gap 1 :valign "bottom"})))

(section "vbox — stacked panels")

(let [top (vtx.style "Top panel — full width" {:border "rounded" :fg ansi.fg.yellow :padding 1 :width 38})
      bot (vtx.style "Bottom panel" {:border "rounded" :fg ansi.fg.white :padding 1 :width 38})]
  (print (vtx.vbox [top bot] {:gap 1})))

(section "confirm — yes/no prompt")

(let [ans (vtx.confirm "Do you want to continue?")]
  (show "confirm" ans))

(section "input — single-line text (with placeholder and history)")

(let [name (vtx.input {:history ["Ada Lovelace" "Grace Hopper" "Barbara Liskov"]
                       :placeholder "e.g. Ada Lovelace"
                       :prompt "Your name: "
                       :prompt-fg ansi.fg.magenta})]
  (show "input" name))

(section "input — ghost completion (type to filter, tab to accept)")

(let [langs ["Fennel"
             "Clojure"
             "Haskell"
             "Rust"
             "Go"
             "Python"
             "TypeScript"
             "Lua"
             "Zig"
             "Elixir"]
      pick (vtx.input {:complete
                       (fn [buf]
                         (let [low (buf:lower)]
                           (icollect [_ l (ipairs langs)] (when (: (l:lower) "find" low 1 true)
                                                            l))))
                       :placeholder
                       "e.g. Fennel"
                       :prompt
                       "Language: "})]
  (show "input+complete" pick))

(section "num-input — numeric input (↑/↓ step, type, enter confirm)")

(let [n (vtx.num-input {:max 100 :min 0 :prompt "Age: " :step 1 :value 25})]
  (show "num-input" n))

(let [v (vtx.num-input {:decimals 2 :max 9.99 :min 0.01 :prompt "Price: $" :step 0.25 :value 1.0})]
  (show "num-input decimal" v))

(section "write — multi-line editor (ctrl-d submit, ctrl-z undo)")

(let [text (vtx.write {:header "Write something:" :height 5 :prompt "  "})]
  (show "write" (when text
                  (let [lines (icollect [l
                                         (text:gmatch "[^
                                                        ]+")] l)]
                    (.. (# lines) " line(s), " (# text) " char(s)")))))

(section "choose — pick one (↑/↓ or j/k, / to search)")

(let [langs ["Fennel" "Clojure" "Haskell" "Rust" "Go" "Python" "TypeScript" "Lua"]
      pick (vtx.choose langs {:height 5})]
  (show "choose" pick))

(section "choose — multi-select (space to toggle, enter to confirm)")

(let [features ["Colors"
                "Borders"
                "Spinner"
                "Input"
                "Multi-line"
                "Fuzzy filter"
                "Table"
                "Pager"]
      picks (vtx.choose features {:height 6 :multi true})]
  (show "choose multi" picks))

(section "checklist — toggle checkboxes (space, a:all, enter confirm)")

(let [options ["Syntax highlighting"
               "Line numbers"
               "Word wrap"
               "Auto-indent"
               "Spell check"
               "Tab completion"
               "Git integration"]
      result (vtx.checklist options {:checked [1 3 6] :height 6})]
  (show "checklist" result))

(section "filter — fuzzy search (type to filter, enter to pick)")

(let [files ["fnl/vtx/ansi.fnl"
             "fnl/vtx/term.fnl"
             "fnl/vtx/posix.fnl"
             "fnl/vtx/util.fnl"
             "fnl/vtx/widget/style.fnl"
             "fnl/vtx/widget/confirm.fnl"
             "fnl/vtx/widget/input.fnl"
             "fnl/vtx/widget/write.fnl"
             "fnl/vtx/widget/choose.fnl"
             "fnl/vtx/widget/filter.fnl"
             "fnl/vtx/widget/spin.fnl"
             "fnl/vtx/widget/password.fnl"
             "fnl/vtx/widget/progress.fnl"
             "fnl/vtx/widget/pager.fnl"
             "fnl/vtx/widget/form.fnl"
             "fnl/vtx/widget/table.fnl"]
      pick (vtx.filter files {:height 7})]
  (show "filter" pick))

(section "filter — multi-select (tab to toggle)")

(let [tags ["bug" "feature" "docs" "refactor" "test" "perf" "breaking" "wontfix"]
      picks (vtx.filter tags {:height 6 :multi true})]
  (show "filter multi" picks))

(section "filter — recent items (shown before query when empty)")

(let [all-cmds ["git commit"
                "git push"
                "git pull"
                "git log"
                "git diff"
                "git status"
                "git stash"
                "git rebase"
                "git cherry-pick"]
      recent ["git push" "git log" "git diff"]
      pick (vtx.filter all-cmds {:height 6 :prompt "Command: " :recent recent})]
  (show "filter+recent" pick))

(section "spin — animated spinner")

(let [result (vtx.spin (fn []
                         (for [i 1 6]
                           (coroutine.yield (.. "Step " i "/6..."))
                           (busy 0.12))
                         "All steps complete") {:spinner "dots" :title "Working..."})]
  (show "spin" result))

(section "multi-spin — parallel tasks")

(vtx.multi-spin [{:f
                  (fn []
                    (for [_ 1 6]
                      (coroutine.yield)
                      (busy 0.12))
                    "ok")
                  :title
                  "Compiling sources"}
                 {:f
                  (fn []
                    (for [_ 1 10]
                      (coroutine.yield)
                      (busy 0.08))
                    "ok")
                  :title
                  "Running tests"}
                 {:f
                  (fn []
                    (for [_ 1 4]
                      (coroutine.yield)
                      (busy 0.18))
                    "ok")
                  :title
                  "Bundling assets"}])

(section "password — masked input (ctrl-r to reveal)")

(let [pw (vtx.password {:prompt "Password: "})]
  (show "password length" (when pw
                            (tostring (# pw)))))

(section "password — with confirm")

(let [pw (vtx.password {:confirm true :confirm-prompt "Confirm password: " :prompt "New password: "})]
  (show "password confirmed" (when pw
                               (tostring (# pw)))))

(section "progress — deterministic bar")

(vtx.progress (fn [update]
                (for [i 1 20]
                  (update i 20)
                  (busy 0.05))) {:title "Loading..." :width 40})

(section "progress — indeterminate (bouncing)")

(vtx.progress (fn [update]
                (for [_ 1 40]
                  (update)
                  (busy 0.04))) {:indeterminate true :title "Fetching..." :width 40})

(section "progress — with ETA and transfer rate")

(vtx.progress (fn [update]
                (for [i 1 60]
                  (update (* i 170000) (* 60 170000))
                  (busy 0.04))) {:show-eta true :show-rate true :title "Downloading..." :unit "B" :width 44})

(section "multi-progress — stacked bars for parallel tasks")

(let [t1 {:f
          (fn [update]
            (for [i 1 30]
              (update i 30)
              (busy 0.05)))
          :title
          "Compiling"}
      t2 {:f
          (fn [update]
            (for [i 1 20]
              (update i 20)
              (busy 0.07)))
          :title
          "Running tests"}
      t3 {:f
          (fn [update]
            (for [i 1 15]
              (update i 15)
              (busy 0.09)))
          :title
          "Bundling assets"}]
  (vtx.multi-progress [t1 t2 t3]))

(section "pager — scrollable text (/ search, <n>G jump, w wrap, l line#, q quit)")

(let [lines {}]
  (for [i 1 80]
    (table.insert lines (string.format "Line %3d: The quick brown fox jumps over the lazy dog. Sphinx of black quartz, judge my vow." i)))
  (vtx.pager (table.concat lines "\n") {:height 12}))

(section "toast — timed inline notifications")

(vtx.toast "Build succeeded in 1.4s" {:level "success" :timeout 1.5})

(vtx.toast "Deprecated API usage detected" {:level "warn" :timeout 1.5})

(vtx.toast "Connection refused on port 5432" {:level "error" :timeout 1.5})

(vtx.toast "Watching for file changes..." {:level "info" :timeout 1.5})

(section "themes — pick one to apply for the rest of the demo")

(let [theme-names (icollect [k _ (pairs vtx.themes)] k)]
  (table.sort theme-names)
  (let [pick (vtx.filter theme-names {:height 6 :prompt "Theme: "})]
    (when (and pick (. pick 1))
      (vtx.set-theme (. pick 1))
      (print (ansi.style (.. "Theme set: " (. pick 1)) ansi.dim)))))

(section "tbl — interactive table (< > sort, s reverse, 0 clear)")

(let [headers ["Name" "Language" "Stars" "License"]
      rows [["Fennel" "Lua" "2.1k" "MIT"]
            ["Janet" "C" "3.4k" "MIT"]
            ["Hy" "Python" "4.8k" "Apache-2"]
            ["Wisp" "JS" "0.9k" "MIT"]
            ["Carp" "C" "1.5k" "Apache-2"]
            ["Squint" "JS" "0.6k" "EPL-1"]
            ["Babashka" "GraalVM" "4.2k" "EPL-1"]]
      row (vtx.tbl headers rows {:height 6})]
  (show "tbl selected" row))

(section "tbl — multi-select (space toggle, enter confirm)")

(let [headers ["Package" "Version" "Status"]
      rows [["fennel" "1.5.0" "up-to-date"]
            ["luasocket" "3.1.0" "up-to-date"]
            ["luafilesystem" "1.8.0" "outdated"]
            ["lua-cjson" "2.1.0" "up-to-date"]
            ["inspect" "3.1.3" "outdated"]
            ["busted" "2.2.0" "up-to-date"]]
      picks (vtx.tbl headers rows {:height 6 :multi true})]
  (show "tbl multi" picks))

(section "separator — horizontal rule")

(print (vtx.separator {:fg ansi.fg.cyan :width 50}))

(print (vtx.separator {:label "section" :width 50}))

(print (vtx.separator {:border "double" :label "double" :width 50}))

(section "key-help — keybinding legend")

(print (vtx.key-help [{:desc "navigate" :key "↑↓"}
                      {:desc "select" :key "space"}
                      {:desc "confirm" :key "enter"}
                      {:desc "quit" :key "q"}] {}))

(section "slider — numeric range input (←→ or h/l, enter confirm)")

(let [v (vtx.slider {:max 100 :min 0 :prompt "Volume: " :step 5 :value 50 :width 30})]
  (show "slider" v))

(section "autocomplete — input with suggestion dropdown (tab accepts, enter confirms)")

(let [langs ["Fennel"
             "Clojure"
             "Haskell"
             "Rust"
             "Go"
             "Python"
             "TypeScript"
             "Lua"
             "Zig"
             "Elixir"]
      pick (vtx.autocomplete langs {:prompt "Language: "})]
  (show "autocomplete" pick))

(section "tree — expandable hierarchy (space toggle, enter select leaf)")

(let [nodes [{:children
              [{:children [{:label "grandchild-a"} {:label "grandchild-b"}]
                :label "child-1"}
               {:label "child-2"}]
              :label
              "root-a"}
             {:children [{:label "leaf-x"} {:label "leaf-y"}] :label "root-b"}
             {:label "root-c (leaf)"}]
      pick (vtx.tree nodes {:height 8})]
  (show "tree" pick))

(section "file-picker — filesystem browser (←→ navigate, enter select)")

(let [pick (vtx.file-picker {:height 10 :path "."})]
  (show "file-picker" pick))

(section "tabs — tabbed content (←→ or h/l switch, enter confirm)")

(let [nl (string.char 10)
      idx (vtx.tabs [{:content
                      (vtx.style (.. "First tab content" nl "Line 2 of tab 1") {:fg ansi.fg.cyan})
                      :label
                      "Overview"}
                     {:content (vtx.style "Second tab content" {:fg ansi.fg.green})
                      :label "Details"}
                     {:content
                      (vtx.style (.. "Third tab" nl "Line 2" nl "Line 3") {:fg ansi.fg.yellow})
                      :label
                      "Settings"}])]
  (show "tabs selected" idx))

(section "style wrap — long text wrapped to box width")

(print (vtx.style "The quick brown fox jumps over the lazy dog. This text should wrap automatically within the border." {:border "rounded" :padding 1 :width 40 :wrap true}))

(section "radio — single-select list (space select, enter confirm)")

(let [editions ["Community" "Professional" "Enterprise"]
      pick (vtx.radio editions {:prompt "Edition:"})]
  (show "radio" pick))

(section "gradient-text — per-character fg color sweep")

(print (vtx.gradient-text "The quick brown fox jumps over the lazy dog" ["#ff0000" "#ff8800" "#ffff00" "#00ff00" "#0088ff" "#8800ff"]))

(section "gradient-lines — per-line fg color sweep")

(let [banner (vtx.style "Tiki
TUI
Library" {:align "center" :border "rounded" :padding 1 :width 20})]
  (print (vtx.gradient-lines banner ["#ff6ec7" "#ff0099" "#cc00ff"])))

(section "gradient-bg-lines — per-line bg color sweep")

(let [block "  sunset  
vibes  
colors  "]
  (print (vtx.gradient-bg-lines block ["#ff4500" "#ff8c00" "#ffd700"])))

(section "place — align content in a fixed canvas")

(let [box (vtx.style "center" {:border "rounded" :fg ansi.fg.cyan})
      canvas (vtx.place box {:halign "center" :height 5 :valign "middle" :width 40})]
  (print canvas))

(section "height-of / width-of — measure rendered text")

(let [text (vtx.style "hello
world" {:border "rounded" :padding 1})]
  (print (.. "width-of:  " (tostring (vtx.width-of text))))
  (print (.. "height-of: " (tostring (vtx.height-of text)))))

(section "form — sequential field collection")

(let [result (vtx.form [{:key "name"
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

(section "wrap — word-wrap a string to a given width")

(let [long "The quick brown fox jumps over the lazy dog. Sphinx of black quartz, judge my vow."
      wrapped (vtx.wrap long 40)]
  (print (vtx.style wrapped {:border "rounded" :fg ansi.fg.white})))

(section "gauge — static value bar")

(print (vtx.gauge 0.75 nil {:label "CPU" :width 30}))

(print (vtx.gauge 45 100 {:label "Memory" :width 30}))

(print (vtx.gauge 0.0 nil {:label "Disk" :width 30}))

(section "sparkline — inline mini bar chart")

(let [loads [0.1 0.3 0.8 0.6 0.4 0.9 0.5 0.2 0.7 0.85 0.3 0.5]]
  (print (vtx.sparkline loads {:label "Load:"}))
  (print (vtx.sparkline [10 40 30 80 60 20 90 50] {:fg ansi.fg.green :label "Reqs:"})))

(section "dialog — modal with buttons (←→ navigate, enter confirm)")

(let [choice (vtx.dialog "Are you sure you want to delete this file?" ["Delete" "Cancel"])]
  (show "dialog" choice))

(section "date-picker — YYYY-MM-DD entry (←→ segments, ↑↓ adjust, enter confirm)")

(let [date (vtx.date-picker {:prompt "Date: "})]
  (show "date-picker" date))

(section "multi-form — all fields at once (tab/enter navigate, enter on last submits)")

(let [result (vtx.multi-form [{:key "name" :label "Name" :type "input"}
                              {:key "age"
                               :label "Age"
                               :opts {:max 120 :min 0 :step 1 :value 25}
                               :type "num"}
                              {:key "ok" :label "Accept terms" :type "confirm"}])]
  (show "multi-form" result))

(section "viewport — scrollable content (↑↓/j/k scroll, q quit)")

(let [lines {}]
  (for [i 1 50]
    (table.insert lines (string.format "Line %2d: The quick brown fox jumps over the lazy dog." i)))
  (vtx.viewport (table.concat lines "\n") {:height 8}))

(section "clipboard — copy to and paste from system clipboard")

(let [text "vtx clipboard demo"]
  (vtx.clipboard-copy text)
  (let [pasted (vtx.clipboard-paste)]
    (show "clipboard-copy/paste" (if (= pasted text)
                                     "ok (round-trip matched)"
                                     pasted))))

(section "theme — tron (electric green, cyan accent)")

(vtx.set-theme "tron")

(let [ans (vtx.confirm "tron theme: continue?")]
  (show "confirm" ans))

(let [pick (vtx.filter ["Fennel" "Clojure" "Haskell" "Rust" "Go" "Lua" "Zig"] {:prompt "filter: "})]
  (show "filter" pick))

(let [choice (vtx.choose ["Option A" "Option B" "Option C" "Option D"])]
  (show "choose" choice))

(vtx.set-theme {})

(print (.. "\n" (vtx.style "All done!" {:bold true :border "rounded" :fg ansi.fg.green :padding 1})))
