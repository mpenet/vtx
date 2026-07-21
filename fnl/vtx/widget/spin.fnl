(local posix (require "vtx.posix"))

(local ansi (require "vtx.ansi"))

(local theme (require "vtx.theme"))

(local spinners {:arrow ["←" "↖" "↑" "↗" "→" "↘" "↓" "↙"]
                 :bounce ["⠁" "⠂" "⠄" "⠂"]
                 :dots ["⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷"]
                 :dots2 ["⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"]
                 :line ["-" "\\" "|" "/"]})

(local default-opts {:interval 80 :spinner "dots" :spinner-fg ansi.fg.cyan :title ""})

(fn draw-frame [frame-str title]
  (posix.write (.. "\r" frame-str " " title ansi.screen.clear-right)))

(fn clear []
  (posix.write (.. "\r" ansi.screen.clear-right ansi.cursor.show)))

(fn spin [f user-opts]
  (let [opts (theme.merge default-opts user-opts)]
    (let [frames (or (. spinners opts.spinner) spinners.dots)
          n (# frames)
          interval (/ opts.interval 1000)
          co (coroutine.create f)]
      (posix.write ansi.cursor.hide)
      (var frame 1)
      (var result nil)
      (var running true)
      (var current-title opts.title)
      (while running
        (draw-frame (ansi.style (. frames frame) opts.spinner-fg) current-title)
        (posix.sleep interval)
        (let [(ok val) (coroutine.resume co)]
          (if (not ok)
              (do
                (pcall clear)
                (error val))
              (if (= (coroutine.status co) "dead")
                  (do
                    (set result val)
                    (set running false))
                  (do
                    (when (= (type val) "string")
                      (set current-title val))
                    (set frame (+ (% frame n) 1)))))))
      (clear)
      result)))

(fn multi-spin [tasks user-opts]
  (let [opts (theme.merge default-opts user-opts)]
    (let [frames (or (. spinners opts.spinner) spinners.dots)
          nf (# frames)
          interval (/ opts.interval 1000)
          ntasks (# tasks)
          cos {}
          titles {}
          results {}
          done {}]
      (each [i task (ipairs tasks)]
        (tset cos i (coroutine.create task.f))
        (tset titles i (or task.title ""))
        (tset results i nil)
        (tset done i false))
      (posix.write ansi.cursor.hide)
      (var frame 1)
      (var ndone 0)
      (var running true)
      (var first-err nil)
      (while running
        (for [i 1 ntasks]
          (let [spinner-char (if (. done i)
                                 (ansi.style "✓" ansi.fg.green)
                                 (ansi.style (. frames frame) opts.spinner-fg))]
            (posix.write (.. "\r" spinner-char " " (. titles i) ansi.screen.clear-right "\r
"))))
        (posix.write (ansi.cursor.up ntasks))
        (posix.sleep interval)
        (set frame (+ (% frame nf) 1))
        (for [i 1 ntasks]
          (when (not (. done i))
            (let [(ok val) (coroutine.resume (. cos i))]
              (if (not ok)
                  (do
                    (when (not first-err)
                      (set first-err val))
                    (tset done i true)
                    (set ndone (+ ndone 1)))
                  (if (= (coroutine.status (. cos i)) "dead")
                      (do
                        (tset done i true)
                        (tset results i val)
                        (set ndone (+ ndone 1)))
                      (when (= (type val) "string")
                        (tset titles i val)))))))
        (when (= ndone ntasks)
          (set running false)))
      (for [_ 1 ntasks]
        (posix.write (.. "\r" ansi.screen.clear-right "\r
")))
      (posix.write (ansi.cursor.up ntasks))
      (posix.write ansi.cursor.show)
      (when first-err
        (error first-err))
      results)))

{:multi-spin multi-spin :spin spin :spinners spinners}
