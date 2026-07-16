(local ansi (require "irx.ansi"))

(local tree-m (require "irx.widget.tree"))

(local faith (require "faith"))

(local opts
  {:collapsed-char "▶"
   :cursor-fg ansi.fg.cyan
   :dir-fg ansi.fg.blue
   :expanded-char "▼"
   :height 10
   :indent 2
   :leaf-char "•"})

(fn test-build-visible-flat []
  (let [nodes [{:label "a"} {:label "b"} {:label "c"}]
        v (tree-m.build-visible nodes 0 {})]
    (faith.= 3 (# v))))

(fn test-build-visible-collapsed []
  (let [nodes [{:children [{:label "child"}] :label "parent"}]
        v (tree-m.build-visible nodes 0 {})]
    (faith.= 1 (# v))
    (faith.= "parent" (. v 1 :label))))

(fn test-build-visible-expanded []
  (let [nodes [{:children [{:label "child"}] :label "parent"}]
        root (. nodes 1)
        expanded {}
        _ (tset expanded (tostring root) true)
        v (tree-m.build-visible nodes 0 expanded)]
    (faith.= 2 (# v))
    (faith.= "parent" (. v 1 :label))
    (faith.= "child" (. v 2 :label))))

(fn test-build-visible-depth []
  (let [nodes [{:children [{:label "child"}] :label "parent"}]
        root (. nodes 1)
        expanded {}
        _ (tset expanded (tostring root) true)
        v (tree-m.build-visible nodes 0 expanded)]
    (faith.= 0 (. v 1 :depth))
    (faith.= 1 (. v 2 :depth))))

(fn test-build-visible-has-children []
  (let [nodes [{:children [{:label "c"}] :label "p"} {:label "leaf"}]
        v (tree-m.build-visible nodes 0 {})]
    (faith.= true (. v 1 :has-children))
    (faith.= false (. v 2 :has-children))))

(fn test-build-visible-expanded-flag []
  (let [nodes [{:children [{:label "c"}] :label "p"}]
        root (. nodes 1)
        expanded {}
        _ (tset expanded (tostring root) true)
        v (tree-m.build-visible nodes 0 expanded)]
    (faith.= true (. v 1 :expanded))))

(fn test-build-visible-collapsed-flag []
  (let [nodes [{:children [{:label "c"}] :label "p"}]
        v (tree-m.build-visible nodes 0 {})]
    (faith.= false (. v 1 :expanded))))

(fn test-render-item-leaf []
  (let [item {:depth 0 :expanded false :has-children false :label "leaf" :node {}}
        s (ansi.strip (tree-m.render-item item 1 2 opts))]
    (faith.is (: s "find" "leaf" 1 true))
    (faith.is (: s "find" "•" 1 true))))

(fn test-render-item-collapsed-dir []
  (let [item {:depth 0 :expanded false :has-children true :label "dir" :node {}}
        s (ansi.strip (tree-m.render-item item 1 2 opts))]
    (faith.is (: s "find" "▶" 1 true))))

(fn test-render-item-expanded-dir []
  (let [item {:depth 0 :expanded true :has-children true :label "dir" :node {}}
        s (ansi.strip (tree-m.render-item item 1 2 opts))]
    (faith.is (: s "find" "▼" 1 true))))

(fn test-render-item-indent []
  (let [item {:depth 2 :expanded false :has-children false :label "x" :node {}}
        s (ansi.strip (tree-m.render-item item 1 2 opts))]
    (faith.is (: s "find" "    " 1 true))))

(fn test-build-visible-nested []
  (let [child {:label "grandchild"}
        mid {:children [child] :label "mid"}
        root {:children [mid] :label "root"}
        nodes [root]
        expanded {}
        _ (tset expanded (tostring root) true)
        _ (tset expanded (tostring mid) true)
        v (tree-m.build-visible nodes 0 expanded)]
    (faith.= 3 (# v))
    (faith.= 2 (. v 3 :depth))))

{:test-build-visible-collapsed test-build-visible-collapsed
 :test-build-visible-collapsed-flag test-build-visible-collapsed-flag
 :test-build-visible-depth test-build-visible-depth
 :test-build-visible-expanded test-build-visible-expanded
 :test-build-visible-expanded-flag test-build-visible-expanded-flag
 :test-build-visible-flat test-build-visible-flat
 :test-build-visible-has-children test-build-visible-has-children
 :test-build-visible-nested test-build-visible-nested
 :test-render-item-collapsed-dir test-render-item-collapsed-dir
 :test-render-item-expanded-dir test-render-item-expanded-dir
 :test-render-item-indent test-render-item-indent
 :test-render-item-leaf test-render-item-leaf}
