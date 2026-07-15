(local term (require "tiki.term"))

(local ansi (require "tiki.ansi"))

(local util (require "tiki.util"))

(local theme (require "tiki.theme"))

(local default-opts {:complete nil
                     :cursor-fg ansi.fg.green
                     :history []
                     :on-change nil
                     :placeholder ""
                     :prompt "> "
                     :prompt-fg ansi.fg.cyan
                     :value ""})

(fn cursor-char [buf pos cursor-fg]
  (let [ch (if (> (# buf) pos)
               (buf:sub (+ pos 1) (+ pos 1))
               " ")]
    (ansi.style ch ansi.reverse cursor-fg)))

(fn render [buf pos opts]
  (let [prompt (ansi.style opts.prompt opts.prompt-fg)]
    (if (and (= (# buf) 0) (> (# opts.placeholder) 0))
        (.. "\r" prompt (ansi.style opts.placeholder ansi.dim) ansi.screen.clear-right)
        (let [before (buf:sub 1 pos)
              cur (cursor-char buf pos opts.cursor-fg)
              after (if (> (# buf) (+ pos 1))
                        (buf:sub (+ pos 2))
                        "")]
          (.. "\r" prompt before cur after ansi.screen.clear-right)))))

(fn common-prefix [candidates]
  (var pfx (. candidates 1))
  (each [_ c (ipairs candidates)]
    (var j 0)
    (let [maxlen (math.min (# pfx) (# c))]
      (while (and (< j maxlen) (= (pfx:sub (+ j 1) (+ j 1)) (c:sub (+ j 1) (+ j 1))))
        (set j (+ j 1))))
    (set pfx (pfx:sub 1 j)))
  pfx)

(fn input [user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (var buf opts.value)
    (var pos (# buf))
    (var result nil)
    (var undo-buf "")
    (var undo-pos 0)
    (var hist-idx (+ (# opts.history) 1))
    (var saved-buf "")
    (term.with-raw (fn []
                     (var running true)
                     (while running
                       (term.write (render buf pos opts))
                       (let [prev-buf buf
                             k (term.read-key)]
                         (when (not= k "\026")
                           (set undo-buf buf)
                           (set undo-pos pos))
                         (match k
                           (where (or "\r" "\n")) (do
                                                    (set result buf)
                                                    (set running false))
                           "\003" (set running false)
                           (where (or "\b" "\127")) (when (> pos 0)
                                                      (set buf (.. (buf:sub 1 (- pos 1)) (buf:sub (+ pos 1))))
                                                      (set pos (- pos 1)))
                           "delete" (when (< pos (# buf))
                                      (set buf (.. (buf:sub 1 pos) (buf:sub (+ pos 2)))))
                           (where (or "left" "\002")) (when (> pos 0)
                                                        (set pos (- pos 1)))
                           (where (or "right" "\006")) (when (< pos (# buf))
                                                         (set pos (+ pos 1)))
                           (where (or "home" "\001")) (set pos 0)
                           (where (or "end" "\005")) (set pos (# buf))
                           "\v" (set buf (buf:sub 1 pos))
                           "\021" (do
                                    (set buf "")
                                    (set pos 0))
                           (where (or "\023" "\027\127")) (let [prefix (buf:sub 1 pos)
                                                                suffix (buf:sub (+ pos 1))
                                                                new-prefix (prefix:gsub "%S+%s*$" "")]
                                                            (set pos (# new-prefix))
                                                            (set buf (.. new-prefix suffix)))
                           "\027d" (let [suffix (buf:sub (+ pos 1))
                                         new-suffix (suffix:gsub "^%s*%S+" "")]
                                     (set buf (.. (buf:sub 1 pos) new-suffix)))
                           "\027f" (do
                                     (while (and (< pos (# buf)) (not (string.match (buf:sub (+ pos 1) (+ pos 1)) "%s")))
                                       (set pos (+ pos 1)))
                                     (while (and (< pos (# buf)) (string.match (buf:sub (+ pos 1) (+ pos 1)) "%s"))
                                       (set pos (+ pos 1))))
                           "\027b" (do
                                     (while (and (> pos 0) (string.match (buf:sub pos pos) "%s"))
                                       (set pos (- pos 1)))
                                     (while (and (> pos 0) (not (string.match (buf:sub pos pos) "%s")))
                                       (set pos (- pos 1))))
                           "\025" (let [text (util.clipboard-paste)]
                                    (when (and text (> (# text) 0))
                                      (let [pat (.. "[^" (string.char 10) "]+")
                                            line (or (text:match pat) text)]
                                        (set buf (.. (buf:sub 1 pos) line (buf:sub (+ pos 1))))
                                        (set pos (+ pos (# line))))))
                           "\026" (let [tb undo-buf
                                        tp undo-pos]
                                    (set undo-buf buf)
                                    (set undo-pos pos)
                                    (set buf tb)
                                    (set pos tp))
                           "\t" (when opts.complete
                                  (let [candidates (opts.complete buf)]
                                    (when (and candidates (> (# candidates) 0))
                                      (let [pfx (if (= (# candidates) 1)
                                                    (. candidates 1)
                                                    (common-prefix candidates))]
                                        (when (> (# pfx) (# buf))
                                          (set buf pfx)
                                          (set pos (# buf)))))))
                           "\016" (when (> hist-idx 1)
                                    (when (= hist-idx (+ (# opts.history) 1))
                                      (set saved-buf buf))
                                    (set hist-idx (- hist-idx 1))
                                    (set buf (. opts.history hist-idx))
                                    (set pos (# buf)))
                           "\014" (when (<= hist-idx (# opts.history))
                                    (set hist-idx (+ hist-idx 1))
                                    (if (> hist-idx (# opts.history))
                                        (do
                                          (set buf saved-buf)
                                          (set pos (# buf)))
                                        (do
                                          (set buf (. opts.history hist-idx))
                                          (set pos (# buf)))))
                           _ (when (and (= (type k) "string") (= (# k) 1) (>= (string.byte k) 32))
                               (set buf (.. (buf:sub 1 pos) k (buf:sub (+ pos 1))))
                               (set pos (+ pos 1))))
                         (when (and opts.on-change (not= buf prev-buf))
                           (opts.on-change buf))))))
    (term.writeln "")
    result))

{:common-prefix common-prefix :input input}
