(local ansi (require "vtx.ansi"))

(local term (require "vtx.term"))

(local theme (require "vtx.theme"))

(local default-opts
  {:cursor-fg ansi.fg.cyan
   :dir-fg ansi.fg.blue
   :dirs-only false
   :height 10
   :path "."
   :show-hidden false})

(fn shell-quote [s]
  (.. "'" (s:gsub "'" "'\\''") "'"))

(fn list-entries [path show-hidden dirs-only]
  (let [flag (if show-hidden "-1ap" "-1p")
        cmd (.. "ls " flag " -- " (shell-quote path) " 2>/dev/null")
        h (io.popen cmd)
        dirs {}
        files {}]
    (when h
      (each [line (h:lines)]
        (when (not (or (= line "./") (= line "../")))
          (if (= (line:sub -1) "/")
              (table.insert dirs (line:sub 1 -2))
              (when (not dirs-only)
                (table.insert files line)))))
      (h:close))
    (values dirs files)))

(fn resolve-path [base entry]
  (if (= base "/")
      (.. "/" entry)
      (.. base "/" entry)))

(fn parent-path [path]
  (if (= path "/")
      "/"
      (let [clean (path:gsub "/+$" "")
            parent (clean:match "^(.+)/[^/]+$")]
        (or parent "/"))))

(fn file-picker [user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (var path opts.path)
    (var cursor 1)
    (var offset 0)
    (var result nil)
    (var last-height 2)
    (term.with-raw
      (fn []
        (var running true)
        (while running
          (let [(dirs files) (list-entries path opts.show-hidden opts.dirs-only)
                entries (do
                          (let [e {}]
                            (each [_ d (ipairs dirs)]
                              (table.insert e {:dir true :name d}))
                            (each [_ f (ipairs files)]
                              (table.insert e {:dir false :name f}))
                            e))
                n (# entries)
                safe-n (math.max 1 n)
                height (math.min opts.height safe-n)]
            (set last-height (+ 1 height))
            (set cursor (math.max 1 (math.min cursor safe-n)))
            (when (< cursor (+ offset 1))
              (set offset (- cursor 1)))
            (when (> cursor (+ offset height))
              (set offset (- cursor height)))
            (term.write (.. "\r" (ansi.style path ansi.bold) ansi.screen.clear-right "\r\n"))
            (for [row 1 height]
              (let [i (+ offset row)
                    entry (. entries i)]
                (term.write (.. "\r"
                                (if entry
                                    (let [base-name (if entry.dir
                                                        (ansi.style (.. entry.name "/") opts.dir-fg)
                                                        entry.name)
                                          line (if (= i cursor)
                                                   (ansi.style base-name ansi.bold opts.cursor-fg)
                                                   base-name)]
                                      line)
                                    "")
                                ansi.screen.clear-right "\r\n"))))
            (term.cursor-up (+ 1 height))
            (let [k (term.read-key)
                  entry (. entries cursor)]
              (match k
                (where (or "up" "k" "\016")) (set cursor (math.max 1 (- cursor 1)))
                (where (or "down" "j" "\014")) (set cursor (math.min n (+ cursor 1)))
                (where (or "right" "\r" "\n")) (when entry
                                                   (if entry.dir
                                                       (do
                                                         (set path (resolve-path path entry.name))
                                                         (set cursor 1)
                                                         (set offset 0))
                                                       (do
                                                         (set result (resolve-path path entry.name))
                                                         (set running false))))
                (where (or "left" "\b" "\127")) (do
                                                    (set path (parent-path path))
                                                    (set cursor 1)
                                                    (set offset 0))
                (where (or "q" "\003" "escape")) (set running false)
                "resize" nil))))))
    (for [_ 1 last-height]
      (term.write (.. "\r" ansi.screen.clear-right "\r\n")))
    (term.cursor-up last-height)
    result))

{:file-picker file-picker :parent-path parent-path :resolve-path resolve-path :shell-quote shell-quote}
