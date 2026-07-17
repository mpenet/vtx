(local ansi (require "vtx.ansi"))

(local term (require "vtx.term"))

(local theme (require "vtx.theme"))

(local util (require "vtx.util"))

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
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (let [expanded {}]
      (var cursor 1)
      (var offset 0)
      (var result nil)
      (term.with-raw (fn []
                       (var running true)
                       (while running
                         (let [visible (build-visible nodes 0 expanded)
                               n (# visible)
                               safe-n (math.max 1 n)
                               height (math.min opts.height safe-n)]
                           (set cursor (math.max 1 (math.min cursor safe-n)))
                           (when (< cursor (+ offset 1))
                             (set offset (- cursor 1)))
                           (when (> cursor (+ offset height))
                             (set offset (- cursor height)))
                           (for [row 1 height]
                             (let [i (+ offset row)
                                   item (. visible i)]
                               (term.write (.. "\r" (if item
                                                        (render-item item i cursor opts)
                                                        "") ansi.screen.clear-right "\r
"))))
                           (term.cursor-up height)
                           (let [k (term.read-key)
                                 item (. visible cursor)]
                             (match k
                               (where (or "up" "k" "\016")) (set cursor (math.max 1 (- cursor 1)))
                               (where (or "down" "j" "\014")) (set cursor (math.min n (+ cursor 1)))
                               (where (or "right" "l")) (when (and item item.has-children)
                                                          (tset expanded (tostring item.node) true))
                               (where (or "left" "h")) (when (and item item.expanded)
                                                         (tset expanded (tostring item.node) false))
                               " " (when (and item item.has-children)
                                     (let [nk (tostring item.node)]
                                       (tset expanded nk (not (. expanded nk)))))
                               (where (or "\r" "\n")) (when item
                                                        (if item.has-children
                                                            (let [nk (tostring item.node)]
                                                              (tset expanded nk (not (. expanded nk))))
                                                            (do
                                                              (set result (or item.node.data item.node.label))
                                                              (set running false))))
                               "g" (set cursor 1)
                               "G" (set cursor n)
                               (where (or "q" "\003" "escape")) (set running false)
                               "resize" nil))))))
      (let [visible (build-visible nodes 0 expanded)
            n (# visible)
            height (math.min opts.height (math.max 1 n))]
        (for [_ 1 height]
          (term.write (.. "\r" ansi.screen.clear-right "\r
")))
        (term.cursor-up height))
      result)))

{:build-visible build-visible :render-item render-item :tree tree}
