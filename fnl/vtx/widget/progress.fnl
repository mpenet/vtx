(local posix (require "vtx.posix"))

(local ansi (require "vtx.ansi"))

(local util (require "vtx.util"))

(local theme (require "vtx.theme"))

(local default-opts {:bar-fg ansi.fg.green
                     :block-size 4
                     :empty "░"
                     :fill "█"
                     :indeterminate false
                     :interval 80
                     :show-eta false
                     :show-rate false
                     :title ""
                     :unit nil
                     :width 40})

(fn fmt-duration [s]
  (let [s (math.floor s)
        h (math.floor (/ s 3600))
        m (math.floor (/ (% s 3600) 60))
        sec (% s 60)]
    (if (> h 0)
        (string.format "%d:%02d:%02d" h m sec)
        (string.format "%d:%02d" m sec))))

(fn fmt-rate [rate unit]
  (if (and unit (= unit "B"))
      (if (>= rate 1000000.0)
          (string.format "%.1f MB/s" (/ rate 1000000.0))
          (>= rate 1000.0)
          (string.format "%.1f KB/s" (/ rate 1000.0))
          (string.format "%.0f B/s" rate))
      (string.format "%.1f/s" rate)))

(fn render [value total opts rate eta]
  (let [pct (if (> total 0)
                (/ value total)
                0)
        filled (math.floor (* pct opts.width))
        bar (.. (util.string-rep opts.fill filled) (util.string-rep opts.empty (- opts.width filled)))
        pct-str (.. (math.floor (* pct 100)) "%")
        rate-str (if (and opts.show-rate rate (> rate 0))
                     (.. " " (fmt-rate rate opts.unit))
                     "")
        eta-str (if (and opts.show-eta eta (> eta 0))
                    (.. " ETA " (fmt-duration eta))
                    "")
        title-str (if (> (# opts.title) 0)
                      (.. " " opts.title)
                      "")]
    (.. "\r" (ansi.style (.. "[" bar "]") opts.bar-fg) " " pct-str rate-str eta-str title-str ansi.screen.clear-right)))

(fn render-bounce [pos opts]
  (let [bs opts.block-size
        bar (let [b {}]
              (for [i 1 opts.width]
                (if (and (>= i pos) (< i (+ pos bs)))
                    (table.insert b opts.fill)
                    (table.insert b opts.empty)))
              (table.concat b))]
    (.. "\r" (ansi.style (.. "[" bar "]") opts.bar-fg) " ..." (if (> (# opts.title) 0)
                                                                  (.. " " opts.title)
                                                                  "") ansi.screen.clear-right)))

(fn render-task-bar [state opts]
  (let [pct (if (and state.total (> state.total 0))
                (math.min 1 (/ state.value state.total))
                0)
        filled (math.floor (* pct opts.width))
        bar (.. (util.string-rep opts.fill filled) (util.string-rep opts.empty (- opts.width filled)))
        pct-str (string.format " %3d%%" (math.floor (* pct 100)))
        done-mark (if state.done
                      (ansi.style " ✓" ansi.fg.green)
                      "")]
    (.. (ansi.style (.. "[" bar "]") opts.bar-fg) pct-str " " state.title done-mark ansi.screen.clear-right)))

(fn progress [f user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (posix.write ansi.cursor.hide)
    (var bounce-pos 1)
    (var bounce-dir 1)
    (var last-value 0)
    (var last-clock (os.clock))
    (var current-rate 0)
    (local update (if opts.indeterminate
                      (fn []
                        (posix.write (render-bounce bounce-pos opts))
                        (io.stdout:flush)
                        (let [max-pos (- opts.width opts.block-size)]
                          (set bounce-pos (+ bounce-pos bounce-dir))
                          (when (or (>= bounce-pos max-pos) (<= bounce-pos 1))
                            (set bounce-dir (- bounce-dir)))))
                      (fn [value ?total]
                        (let [total (or ?total 100)
                              now (os.clock)
                              dt (- now last-clock)]
                          (when (> dt 0)
                            (set current-rate (/ (- value last-value) dt)))
                          (set last-value value)
                          (set last-clock now)
                          (let [eta (if (and opts.show-eta (> current-rate 0) (> total value))
                                        (/ (- total value) current-rate)
                                        nil)]
                            (posix.write (render value total opts (when opts.show-rate
                                                                    current-rate) eta)))
                          (io.stdout:flush)))))
    (let [(ok err) (pcall f update)]
      (posix.write (.. "\r" ansi.screen.clear-right ansi.cursor.show))
      (when (not ok)
        (error err)))))

(fn multi-progress [tasks user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (let [ntasks (# tasks)
          states {}
          cos {}]
      (each [i task (ipairs tasks)]
        (let [state {:done false :title (or task.title "") :total 1 :value 0}]
          (tset states i state)
          (tset cos i (coroutine.create (fn []
                                          (task.f (fn [v total]
                                                    (set state.value v)
                                                    (set state.total (or total 1))
                                                    (coroutine.yield))))))))
      (posix.write ansi.cursor.hide)
      (var ndone 0)
      (var running true)
      (var first-err nil)
      (while running
        (for [i 1 ntasks]
          (posix.write (.. "\r" (render-task-bar (. states i) opts) "\r
")))
        (posix.write (ansi.cursor.up ntasks))
        (posix.sleep (/ opts.interval 1000))
        (for [i 1 ntasks]
          (let [state (. states i)]
            (when (not state.done)
              (let [(ok val) (coroutine.resume (. cos i))]
                (when (not ok)
                  (when (not first-err)
                    (set first-err val)))
                (when (or (not ok) (= (coroutine.status (. cos i)) "dead"))
                  (set state.done true)
                  (set ndone (+ ndone 1)))))))
        (when (= ndone ntasks)
          (set running false)))
      (for [i 1 ntasks]
        (posix.write (.. "\r" (render-task-bar (. states i) opts) "\r
")))
      (posix.write (ansi.cursor.up ntasks))
      (posix.sleep 0.3)
      (for [_ 1 ntasks]
        (posix.write (.. "\r" ansi.screen.clear-right "\r
")))
      (posix.write (ansi.cursor.up ntasks))
      (posix.write ansi.cursor.show)
      (when first-err
        (error first-err)))))

{:fmt-duration fmt-duration
 :fmt-rate fmt-rate
 :multi-progress multi-progress
 :progress progress
 :render-task-bar render-task-bar}
