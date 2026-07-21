(local ansi (require "vtx.ansi"))

(local term (require "vtx.term"))

(local theme (require "vtx.theme"))

(local util (require "vtx.util"))

(local list-nav (require "vtx.list-nav"))

(local default-opts {:collapsed-char "▶"
                     :cursor-fg ansi.fg.cyan
                     :dir-fg ansi.fg.blue
                     :expanded-char "▼"
                     :height 10
                     :indent 2
                     :leaf-char "•"})

(fn build-visible [nodes depth expanded]
  (let [result {}]
    (each [_ node (ipairs nodes)]
      (let [has-ch (if (and node.children (> (# node.children) 0))
                       true
                       false)
            node-key (tostring node)
            is-exp (if (and has-ch (. expanded node-key))
                       true
                       false)]
        (table.insert result {:depth depth
                              :expanded is-exp
                              :has-children has-ch
                              :label node.label
                              :node node})
        (when is-exp
          (each [_ child (ipairs (build-visible node.children (+ depth 1) expanded))]
            (table.insert result child)))))
    result))

(fn render-item [item i cursor opts]
  (let [indent (util.string-rep " " (* item.depth opts.indent))
        prefix (if item.has-children
                   (if item.expanded
                       opts.expanded-char
                       opts.collapsed-char)
                   opts.leaf-char)
        is-cur (= i cursor)
        label (if is-cur
                  (ansi.style item.label ansi.bold opts.cursor-fg)
                  (if item.has-children
                      (ansi.style item.label opts.dir-fg)
                      item.label))]
    (.. indent prefix " " label)))

(fn tree [nodes user-opts]
  (let [opts (theme.merge default-opts user-opts)
        expanded {}
        nav (list-nav.make-state 1 opts.height)
        fcache (term.make-frame-cache)]
    (var result nil)
    (var cached-visible nil)
    (var cache-dirty true)
    (fn get-visible []
      (when cache-dirty
        (set cached-visible (build-visible nodes 0 expanded))
        (set cache-dirty false))
      cached-visible)
    (fn invalidate []
      (set cache-dirty true))
    (term.with-raw (fn []
                     (var running true)
                     (while running
                       (let [visible (get-visible)]
                         (list-nav.set-n nav (# visible))
                         (list-nav.clamp nav)
                         (term.render-frame fcache (fn [push]
                                                     (list-nav.each-visible nav (fn [_row i _is-cursor]
                                                                                  (let [item (. visible i)]
                                                                                    (push (.. "\r" (if item
                                                                                                       (render-item item i nav.cursor opts)
                                                                                                       "") ansi.screen.clear-right "\r
")))))
                                                     (push (ansi.cursor.up (list-nav.visible-height nav)))))
                         (let [k (term.read-key)
                               item (. visible nav.cursor)]
                           (if (list-nav.handle-key nav k)
                               nil
                               (match k
                                 (where (or "right" "l")) (when (and item item.has-children)
                                                            (tset expanded (tostring item.node) true)
                                                            (invalidate))
                                 (where (or "left" "h")) (when (and item item.expanded)
                                                           (tset expanded (tostring item.node) false)
                                                           (invalidate))
                                 " " (when (and item item.has-children)
                                       (let [nk (tostring item.node)]
                                         (tset expanded nk (not (. expanded nk)))
                                         (invalidate)))
                                 (where (or "\r" "\n")) (when item
                                                          (if item.has-children
                                                              (let [nk (tostring item.node)]
                                                                (tset expanded nk (not (. expanded nk)))
                                                                (invalidate))
                                                              (do
                                                                (set result (or item.node.data item.node.label))
                                                                (set running false))))
                                 (where (or "q" "\003" "escape")) (set running false)
                                 "resize" nil)))))))
    (let [visible (get-visible)
          n (# visible)
          height (math.min opts.height (math.max 1 n))]
      (term.clear-rows height))
    result))

{:build-visible build-visible :render-item render-item :tree tree}
