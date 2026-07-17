(local term (require "vtx.term"))

(local ansi (require "vtx.ansi"))

(local util (require "vtx.util"))

(local theme (require "vtx.theme"))

(local default-opts {:confirm false
                     :confirm-prompt "Confirm: "
                     :cursor-fg ansi.fg.green
                     :mask "•"
                     :prompt "> "
                     :prompt-fg ansi.fg.cyan})

(fn render [buf pos opts prompt-str visible]
  (let [n (# buf)
        p (ansi.style (or prompt-str opts.prompt) opts.prompt-fg)]
    (if visible
        (let [before (buf:sub 1 pos)
              cur (ansi.style (if (< pos n)
                                  (buf:sub (+ pos 1) (+ pos 1))
                                  " ") ansi.reverse opts.cursor-fg)
              after (if (< pos n)
                        (buf:sub (+ pos 2))
                        "")]
          (.. "\r" p before cur after ansi.screen.clear-right))
        (let [before (util.string-rep opts.mask pos)
              cur (ansi.style (if (< pos n)
                                  opts.mask
                                  " ") ansi.reverse opts.cursor-fg)
              after (util.string-rep opts.mask (math.max 0 (- n pos 1)))]
          (.. "\r" p before cur after ansi.screen.clear-right)))))

(fn read-password [opts prompt-str]
  (var buf "")
  (var pos 0)
  (var result nil)
  (var showing false)
  (term.with-raw (fn []
                   (var running true)
                   (while running
                     (term.write (render buf pos opts prompt-str showing))
                     (let [k (term.read-key)]
                       (match k
                         (where (or "\r" "\n")) (do
                                                  (set result buf)
                                                  (set running false))
                         "\003" (set running false)
                         "\018" (set showing (not showing))
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
                         _ (when (and (= (type k) "string") (= (# k) 1) (>= (string.byte k) 32))
                             (set buf (.. (buf:sub 1 pos) k (buf:sub (+ pos 1))))
                             (set pos (+ pos 1))))))))
  (term.writeln "")
  result)

(fn password [user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (if opts.confirm
        (let [pw1 (read-password opts nil)]
          (when pw1
            (let [pw2 (read-password opts opts.confirm-prompt)]
              (if (and pw2 (= pw1 pw2))
                  pw1
                  (do
                    (term.writeln "Passwords do not match.")
                    nil)))))
        (read-password opts nil))))

{:password password :render render}
