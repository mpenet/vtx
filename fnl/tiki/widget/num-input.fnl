(local term (require "tiki.term"))

(local ansi (require "tiki.ansi"))

(local theme (require "tiki.theme"))

(local default-opts {:decimals 0
                     :max nil
                     :min nil
                     :prompt "> "
                     :prompt-fg ansi.fg.cyan
                     :step 1
                     :value 0
                     :value-fg ansi.fg.green})

(fn clamp [v lo hi]
  (if (and lo (< v lo))
      lo
      (and hi (> v hi))
      hi
      v))

(fn fmt [n decimals]
  (if (= decimals 0)
      (tostring (math.floor n))
      (string.format (.. "%." decimals "f") n)))

(fn valid? [n opts]
  (when (and n (or (not opts.min) (>= n opts.min)) (or (not opts.max) (<= n opts.max)))
    true))

(fn render [buf opts]
  (let [n (tonumber buf)
        ok (valid? n opts)
        val-str (if (= (# buf) 0)
                    (ansi.style "·" ansi.dim)
                    ok
                    (ansi.style buf opts.value-fg)
                    (ansi.style buf ansi.fg.red))
        range-str (.. (if opts.min
                          (.. " min:" (fmt opts.min opts.decimals))
                          "") (if opts.max
                                  (.. " max:" (fmt opts.max opts.decimals))
                                  ""))
        hint (ansi.style (.. " [↑/↓ ±" (fmt opts.step opts.decimals) range-str "]") ansi.dim)]
    (.. "\r" (ansi.style opts.prompt opts.prompt-fg) val-str hint ansi.screen.clear-right)))

(fn step-value [buf base-val delta opts]
  (let [n (or (tonumber buf) base-val)
        new-n (clamp (+ n delta) opts.min opts.max)]
    (fmt new-n opts.decimals)))

(fn num-input [user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (var buf (fmt opts.value opts.decimals))
    (var result nil)
    (term.with-raw (fn []
                     (var running true)
                     (while running
                       (term.write (render buf opts))
                       (let [k (term.read-key)]
                         (match k
                           (where (or "\r" "\n")) (let [n (tonumber buf)]
                                                    (when (valid? n opts)
                                                      (set result n)
                                                      (set running false)))
                           "\003" (set running false)
                           (where (or "up" "k")) (set buf (step-value buf opts.value opts.step opts))
                           (where (or "down" "j")) (set buf (step-value buf opts.value (- opts.step) opts))
                           "page-up" (set buf (step-value buf opts.value (* 10 opts.step) opts))
                           "page-down" (set buf (step-value buf opts.value (* -10 opts.step) opts))
                           (where (or "home" "\001")) (when opts.min
                                                        (set buf (fmt opts.min opts.decimals)))
                           (where (or "end" "\005")) (when opts.max
                                                       (set buf (fmt opts.max opts.decimals)))
                           (where (or "\b" "\127")) (when (> (# buf) 0)
                                                      (set buf (buf:sub 1 (- (# buf) 1))))
                           "\021" (set buf "")
                           _ (when (and (= (type k) "string") (= (# k) 1))
                               (when (or (k:match "%d") (and (= k "-") (= (# buf) 0)) (and (= k ".") (> opts.decimals 0) (not (buf:find "." 1 true))))
                                 (set buf (.. buf k)))))))) {})
    (term.writeln "")
    result))

{:fmt fmt :num-input num-input :valid? valid?}
