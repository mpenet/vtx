(local ansi (require "vtx.ansi"))

(local tabs-m (require "vtx.widget.tabs"))

(local faith (require "faith"))

(local opts
  {:active-fg ansi.fg.cyan
   :inactive-fg ansi.dim})

(local tab-list
  [{:content "content one" :label "Tab1"}
   {:content "content two\nline two" :label "Tab2"}
   {:content "content three" :label "Tab3"}])

(fn test-tab-bar-contains-labels []
  (let [bar (ansi.strip (tabs-m.render-tab-bar tab-list 1 opts))]
    (faith.is (: bar "find" "Tab1" 1 true))
    (faith.is (: bar "find" "Tab2" 1 true))
    (faith.is (: bar "find" "Tab3" 1 true))))

(fn test-tab-bar-active-has-box []
  (let [bar (ansi.strip (tabs-m.render-tab-bar tab-list 1 opts))]
    (faith.is (: bar "find" "│ Tab1 │" 1 true))
    (faith.is (: bar "find" "╭" 1 true))
    (faith.is (: bar "find" "╰" 1 true))))

(fn test-tab-bar-inactive-no-box []
  (let [bar (ansi.strip (tabs-m.render-tab-bar tab-list 1 opts))]
    (faith.= nil (: bar "find" "│ Tab2 │" 1 true))))

(fn test-tab-bar-active-index-2 []
  (let [bar (ansi.strip (tabs-m.render-tab-bar tab-list 2 opts))]
    (faith.is (: bar "find" "│ Tab2 │" 1 true))
    (faith.= nil (: bar "find" "│ Tab1 │" 1 true))))

(fn test-tab-bar-has-separator []
  (let [bar (ansi.strip (tabs-m.render-tab-bar tab-list 1 opts))]
    (faith.is (: bar "find" "─" 1 true))))

(fn test-tab-bar-single []
  (let [single [{:content "" :label "Only"}]
        bar (ansi.strip (tabs-m.render-tab-bar single 1 opts))]
    (faith.is (: bar "find" "│ Only │" 1 true))))

(fn test-tab-bar-has-ansi []
  (let [bar (tabs-m.render-tab-bar tab-list 1 opts)]
    (faith.is (: bar "find" "\027" 1 true))))

{:test-tab-bar-active-has-box test-tab-bar-active-has-box
 :test-tab-bar-active-index-2 test-tab-bar-active-index-2
 :test-tab-bar-contains-labels test-tab-bar-contains-labels
 :test-tab-bar-has-ansi test-tab-bar-has-ansi
 :test-tab-bar-has-separator test-tab-bar-has-separator
 :test-tab-bar-inactive-no-box test-tab-bar-inactive-no-box
 :test-tab-bar-single test-tab-bar-single}
