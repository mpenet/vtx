(local ansi (require "vtx.ansi"))

(local term (require "vtx.term"))

(local theme (require "vtx.theme"))

(local list-nav (require "vtx.list-nav"))

(local default-opts {:cursor-fg ansi.fg.cyan
                     :dir-fg ansi.fg.blue
                     :dirs-only false
                     :height 10
                     :path "."
                     :show-hidden false})

(fn shell-quote [s]
  (.. "'" (s:gsub "'" "'\\''") "'"))

(fn list-entries [path show-hidden dirs-only]
  (let [flag (if show-hidden
                 "-1ap"
                 "-1p")
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
  (let [opts (theme.merge default-opts user-opts)
        nav (list-nav.make-state 1 opts.height)]
    (var path opts.path)
    (var result nil)
    (var last-height 2)
    (var cached-path nil)
    (var cached-entries [])
    (fn refresh-entries []
      (let [(dirs files) (list-entries path opts.show-hidden opts.dirs-only)
            e {}]
        (each [_ d (ipairs dirs)]
          (table.insert e {:dir true :name d}))
        (each [_ f (ipairs files)]
          (table.insert e {:dir false :name f}))
        (set cached-entries e)
        (set cached-path path)))
    (fn navigate-to [new-path]
      (set path new-path)
      (set nav.cursor 1)
      (set nav.offset 0))
    (term.with-raw (fn []
                     (var running true)
                     (while running
                       (when (not= path cached-path)
                         (refresh-entries))
                       (list-nav.set-n nav (# cached-entries))
                       (list-nav.clamp nav)
                       (let [entries cached-entries
                             height (list-nav.visible-height nav)]
                         (set last-height (+ 1 height))
                         (term.write (.. "\r" (ansi.style path ansi.bold) ansi.screen.clear-right "\r
"))
                         (list-nav.each-visible nav (fn [_row i _is-cursor]
                                                      (let [entry (. entries i)]
                                                        (term.write (.. "\r" (if entry
                                                                                 (let [base-name (if entry.dir
                                                                                                     (ansi.style (.. entry.name "/") opts.dir-fg)
                                                                                                     entry.name)
                                                                                       line (if (= i nav.cursor)
                                                                                                (ansi.style base-name ansi.bold opts.cursor-fg)
                                                                                                base-name)]
                                                                                   line)
                                                                                 "") ansi.screen.clear-right "\r
")))))
                         (term.cursor-up (+ 1 height))
                         (let [k (term.read-key)
                               entry (. entries nav.cursor)]
                           (if (list-nav.handle-key nav k)
                               nil
                               (match k
                                 (where (or "right" "\r" "\n")) (when entry
                                                                  (if entry.dir
                                                                      (navigate-to (resolve-path path entry.name))
                                                                      (do
                                                                        (set result (resolve-path path entry.name))
                                                                        (set running false))))
                                 (where (or "left" "\b" "\127")) (navigate-to (parent-path path))
                                 (where (or "q" "\003" "escape")) (set running false)
                                 "resize" nil)))))))
    (term.clear-rows last-height)
    result))

{:file-picker file-picker
 :parent-path parent-path
 :resolve-path resolve-path
 :shell-quote shell-quote}
