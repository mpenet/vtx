(local posix (require "tiki.posix"))

(local ansi (require "tiki.ansi"))

(local theme (require "tiki.theme"))

(local spinners {:arrow ["←" "↖" "↑" "↗" "→" "↘" "↓" "↙"]
                 :bounce ["⠁" "⠂" "⠄" "⠂"]
                 :dots ["⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷"]
                 :dots2 ["⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"]
                 :line ["-" "\\" "|" "/"]})

(local default-opts {:interval 80 :spinner "dots" :spinner-fg ansi.fg.cyan :title ""})

(fn draw-frame [frame-str title]
  (posix.write (.. "\r" frame-str " " title ansi.screen.clear-right))
  (io.stdout:flush))

(fn clear []
  (posix.write (.. "\r" ansi.screen.clear-right ansi.cursor.show)))

(fn spin [f user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
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
        (let [deadline (+ (os.clock) interval)]
          (while (< (os.clock) deadline)))
        (let [(ok val) (coroutine.resume co)]
          (if (not ok)
              (do
                (clear)
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

{:spin spin :spinners spinners}
