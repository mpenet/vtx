(local term (require "tiki.term"))

(local ansi (require "tiki.ansi"))

(local util (require "tiki.util"))

(local theme (require "tiki.theme"))

(local default-opts {:confirm false
                     :confirm-prompt "Confirm: "
                     :cursor-fg ansi.fg.green
                     :mask "•"
                     :prompt "> "
                     :prompt-fg ansi.fg.cyan})

(fn render [buf pos opts prompt-str]
  (let [n (# buf)
        before (util.string-rep opts.mask pos)
        cur (ansi.style (if (< pos n)
                            opts.mask
                            " ") ansi.reverse opts.cursor-fg)
        after (util.string-rep opts.mask (math.max 0 (- n pos 1)))
        p (ansi.style (or prompt-str opts.prompt) opts.prompt-fg)]
    (.. "\r" p before cur after ansi.screen.clear-right)))

(fn read-password [opts prompt-str]
  (var buf "")
  (var pos 0)
  (var result nil)
  (term.with-raw (fn []
                   (var running true)
                   (while running
                     (term.write (render buf pos opts prompt-str))
                     (let [k (term.read-key)]
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
                    (print "Passwords do not match.")
                    nil)))))
        (read-password opts nil))))

{:password password}
