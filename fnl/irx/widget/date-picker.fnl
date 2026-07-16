(local ansi (require "irx.ansi"))

(local term (require "irx.term"))

(local theme (require "irx.theme"))

(local default-opts
  {:active-fg ansi.fg.cyan
   :fg ansi.fg.white
   :prompt "Date: "
   :separator "-"})

(fn days-in-month [y m]
  (let [leap (and (= (% y 4) 0) (or (not= (% y 100) 0) (= (% y 400) 0)))]
    (. [31 (if leap 29 28) 31 30 31 30 31 31 30 31 30 31] m)))

(fn clamp-day [y m d]
  (math.max 1 (math.min (days-in-month y m) d)))

(fn date-picker [user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (let [init (or opts.value "")
          today (os.date "*t")]
      (var year (or (tonumber (init:match "^(%d%d%d%d)")) today.year))
      (var month (or (tonumber (init:match "^%d%d%d%d%-(%d%d)")) today.month))
      (var day (or (tonumber (init:match "^%d%d%d%d%-%d%d%-(%d%d)")) today.day))
      (var seg 1)
      (var result nil)
      (term.with-raw
        (fn []
          (var running true)
          (while running
            (let [sep opts.separator
                  ys (string.format "%04d" year)
                  ms (string.format "%02d" month)
                  ds (string.format "%02d" day)
                  row (.. (ansi.style opts.prompt opts.fg)
                          (if (= seg 1) (ansi.style ys ansi.bold opts.active-fg) (ansi.style ys opts.fg))
                          sep
                          (if (= seg 2) (ansi.style ms ansi.bold opts.active-fg) (ansi.style ms opts.fg))
                          sep
                          (if (= seg 3) (ansi.style ds ansi.bold opts.active-fg) (ansi.style ds opts.fg)))]
              (term.write (.. "\r" row ansi.screen.clear-right))
              (let [k (term.read-key)]
                (match k
                  (where (or "\t" "right" "l")) (set seg (if (= seg 3) 1 (+ seg 1)))
                  (where (or "left" "h")) (set seg (if (= seg 1) 3 (- seg 1)))
                  "up" (match seg
                         1 (set year (+ year 1))
                         2 (do (set month (if (= month 12) 1 (+ month 1)))
                               (set day (clamp-day year month day)))
                         3 (set day (math.min (days-in-month year month) (+ day 1))))
                  "down" (match seg
                           1 (set year (math.max 1 (- year 1)))
                           2 (do (set month (if (= month 1) 12 (- month 1)))
                                 (set day (clamp-day year month day)))
                           3 (set day (math.max 1 (- day 1))))
                  (where (or "\r" "\n")) (do (set result (string.format "%04d-%02d-%02d" year month day))
                                             (set running false))
                  (where (or "q" "\003" "escape")) (set running false)
                  "resize" nil))))))
      (term.write (.. "\r" ansi.screen.clear-right "\n"))
      result)))

{:clamp-day clamp-day :date-picker date-picker :days-in-month days-in-month}
