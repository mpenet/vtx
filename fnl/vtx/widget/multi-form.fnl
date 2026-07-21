(local ansi (require "vtx.ansi"))

(local term (require "vtx.term"))

(local theme (require "vtx.theme"))

(local util (require "vtx.util"))

(local default-opts {:active-fg ansi.fg.cyan
                     :cursor-char "█"
                     :label-fg ansi.fg.white
                     :value-fg ansi.fg.white})

(fn init-state [field]
  (match field.type
    "confirm" {:value
               (if (= (and field.opts field.opts.default) false)
                   false
                   true)}
    "num" {:value (or (and field.opts field.opts.value) 0)}
    _ {:value (or (and field.opts field.opts.value) "")}))

(fn render-value [field state is-active opts]
  (match field.type
    "confirm" (let [aff (or (and field.opts field.opts.affirmative) "Yes")
                    neg (or (and field.opts field.opts.negative) "No")
                    yes (if state.value
                            (ansi.style aff ansi.bold opts.active-fg)
                            (ansi.style aff opts.value-fg))
                    no (if (not state.value)
                           (ansi.style neg ansi.bold opts.active-fg)
                           (ansi.style neg opts.value-fg))]
                (.. yes "  " no))
    "num" (let [v (tostring state.value)]
            (if is-active
                (ansi.style v ansi.bold opts.active-fg)
                v))
    "password" (let [masked (util.string-rep "•" (# state.value))]
                 (if is-active
                     (.. masked (ansi.style opts.cursor-char opts.active-fg))
                     masked))
    _ (if is-active
          (.. state.value (ansi.style opts.cursor-char opts.active-fg))
          state.value)))

(fn render-field [field state i active opts]
  (let [is-active (= i active)
        label (ansi.style (.. (or field.label "") ": ") (if is-active
                                                            opts.active-fg
                                                            opts.label-fg))
        value (render-value field state is-active opts)]
    (.. label value)))

(fn multi-form [fields user-opts]
  (let [opts (theme.merge default-opts user-opts)]
    (let [n (# fields)
          states (icollect [_ f (ipairs fields)] (init-state f))]
      (var active 1)
      (var result nil)
      (term.with-raw (fn []
                       (var running true)
                       (while running
                         (for [i 1 n]
                           (term.write (.. "\r" (render-field (. fields i) (. states i) i active opts) ansi.screen.clear-right "\r
")))
                         (term.cursor-up n)
                         (let [k (term.read-key)
                               field (. fields active)
                               state (. states active)]
                           (match k
                             "\t" (set active (if (= active n)
                                                  1
                                                  (+ active 1)))
                             (where (or "\r" "\n")) (if (= active n)
                                                        (do
                                                          (set result (collect [i f (ipairs fields)] (values (or f.key f.label (tostring i)) (. states i "value"))))
                                                          (set running false))
                                                        (set active (+ active 1)))
                             (where (or "\003" "escape")) (set running false)
                             _ (let [fo (or field.opts {})
                                     new-state (match field.type
                                                 (where (or "input" "password")) (match k
                                                                                   (where (or "\b" "\127")) {:value (state.value:sub 1 (math.max 0 (- (# state.value) 1)))}
                                                                                   (where c (and (= (# c) 1) (>= (c:byte 1) 32))) {:value (.. state.value c)}
                                                                                   _ state)
                                                 "confirm" (match k
                                                             (where (or "left" "right" " ")) {:value (not state.value)}
                                                             _ state)
                                                 "num" (let [step (or fo.step 1)
                                                             mn (or fo.min (- math.huge))
                                                             mx (or fo.max math.huge)]
                                                         (match k
                                                           "up" {:value (math.min mx (+ state.value step))}
                                                           "down" {:value (math.max mn (- state.value step))}
                                                           _ state))
                                                 _ state)]
                                 (each [key val (pairs new-state)]
                                   (tset (. states active) key val))))))))
      (term.clear-rows n)
      result)))

{:init-state init-state :multi-form multi-form :render-field render-field}
