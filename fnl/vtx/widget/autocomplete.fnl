(local ansi (require "vtx.ansi"))

(local term (require "vtx.term"))

(local theme (require "vtx.theme"))

(local {:filter-items filter-items} (require "vtx.widget.filter"))

(local default-opts
  {:cursor-fg ansi.fg.cyan
   :fuzzy false
   :height 5
   :prompt "> "
   :prompt-fg ansi.fg.cyan})

(fn autocomplete [items user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (var query "")
    (var matches (filter-items items "" opts.fuzzy))
    (var cursor-idx 0)
    (var result nil)
    (var aborted false)
    (term.with-raw
      (fn []
        (var running true)
        (while running
          (set cursor-idx (math.max 0 (math.min cursor-idx (# matches))))
          (term.write (.. "\r" (ansi.style opts.prompt opts.prompt-fg) query ansi.screen.clear-right "\r\n"))
          (for [i 1 opts.height]
            (let [m (. matches i)]
              (term.write (.. "\r"
                              (if m
                                  (.. "  " (if (= i cursor-idx)
                                               (ansi.style m.item ansi.bold opts.cursor-fg)
                                               m.item))
                                  "")
                              ansi.screen.clear-right "\r\n"))))
          (term.cursor-up (+ 1 opts.height))
          (term.cursor-col (+ (ansi.len opts.prompt) (ansi.len query) 1))
          (let [k (term.read-key)]
            (match k
              (where (or "up" "\016")) (set cursor-idx (math.max 0 (- cursor-idx 1)))
              (where (or "down" "\014")) (set cursor-idx (math.min (# matches) (+ cursor-idx 1)))
              "\t" (when (and (> cursor-idx 0) (. matches cursor-idx))
                     (set query (. matches cursor-idx :item))
                     (set matches (filter-items items query opts.fuzzy))
                     (set cursor-idx 0))
              (where (or "\r" "\n")) (do
                                       (set result (if (and (> cursor-idx 0) (. matches cursor-idx))
                                                       (. matches cursor-idx :item)
                                                       (when (> (# query) 0) query)))
                                       (set running false))
              (where (or "\003" "\027")) (do (set aborted true) (set running false))
              (where (or "\b" "\127")) (when (> (# query) 0)
                                         (set query (query:sub 1 (- (# query) 1)))
                                         (set matches (filter-items items query opts.fuzzy))
                                         (set cursor-idx 0))
              "\021" (do
                       (set query "")
                       (set matches (filter-items items "" opts.fuzzy))
                       (set cursor-idx 0))
              "resize" nil
              _ (when (and (= (type k) "string") (= (# k) 1) (>= (string.byte k) 32))
                  (set query (.. query k))
                  (set matches (filter-items items query opts.fuzzy))
                  (set cursor-idx 0)))))))
    (for [_ 1 (+ 1 opts.height)]
      (term.write (.. "\r" ansi.screen.clear-right "\r\n")))
    (term.cursor-up (+ 1 opts.height))
    (when (not aborted) result)))

{:autocomplete autocomplete}
