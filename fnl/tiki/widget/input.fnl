(local term (require "tiki.term"))

(local ansi (require "tiki.ansi"))

(local util (require "tiki.util"))

(local theme (require "tiki.theme"))

(local default-opts {:cursor-fg ansi.fg.green
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
    (term.with-raw (fn []
                     (var running true)
                     (while running
                       (term.write (render buf pos opts))
                       (let [k (term.read-key)]
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
                           _ (when (and (= (type k) "string") (= (# k) 1) (>= (string.byte k) 32))
                               (set buf (.. (buf:sub 1 pos) k (buf:sub (+ pos 1))))
                               (set pos (+ pos 1))))))))
    (term.writeln "")
    result))

{:input input}
