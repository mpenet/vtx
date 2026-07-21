(local list-nav (require "vtx.list-nav"))

(local faith (require "faith"))

(fn test-make-state []
  (let [s (list-nav.make-state 10 5)]
    (faith.= 1 s.cursor)
    (faith.= 0 s.offset)
    (faith.= 10 s.n)
    (faith.= 5 s.height)))

(fn test-clamp-cursor-below-min []
  (let [s (list-nav.make-state 10 5)]
    (set s.cursor 0)
    (list-nav.clamp s)
    (faith.= 1 s.cursor)))

(fn test-clamp-cursor-above-max []
  (let [s (list-nav.make-state 10 5)]
    (set s.cursor 20)
    (list-nav.clamp s)
    (faith.= 10 s.cursor)))

(fn test-clamp-offset-scroll-down []
  (let [s (list-nav.make-state 20 5)]
    (set s.cursor 10)
    (list-nav.clamp s)
    ;; cursor at 10, height 5 → offset must be at least 5
    (faith.= 5 s.offset)))

(fn test-clamp-offset-scroll-up []
  (let [s (list-nav.make-state 20 5)]
    (set s.cursor 10)
    (set s.offset 8)
    (list-nav.clamp s)
    ;; cursor at 10, offset 8 → cursor > offset+height (13), fine
    ;; then move cursor to 3 → offset must be at most 2
    (set s.cursor 3)
    (list-nav.clamp s)
    (faith.= 2 s.offset)))

(fn test-visible-height-truncates-to-n []
  (let [s (list-nav.make-state 3 10)]
    (faith.= 3 (list-nav.visible-height s))))

(fn test-visible-height-full []
  (let [s (list-nav.make-state 20 5)]
    (faith.= 5 (list-nav.visible-height s))))

(fn test-visible-height-min-one []
  (let [s (list-nav.make-state 0 10)]
    (faith.= 1 (list-nav.visible-height s))))

(fn test-each-visible-iterates []
  (let [s (list-nav.make-state 10 3)
        seen []]
    (list-nav.each-visible s (fn [row i is-cursor]
                               (table.insert seen [row i is-cursor])))
    (faith.= 3 (# seen))
    (faith.= [1 1 true] (. seen 1))
    (faith.= [2 2 false] (. seen 2))
    (faith.= [3 3 false] (. seen 3))))

(fn test-each-visible-with-offset []
  (let [s (list-nav.make-state 10 3)
        seen []]
    (set s.offset 5)
    (set s.cursor 6)
    (list-nav.each-visible s (fn [row i is-cursor]
                               (table.insert seen [row i is-cursor])))
    (faith.= [1 6 true] (. seen 1))
    (faith.= [2 7 false] (. seen 2))
    (faith.= [3 8 false] (. seen 3))))

(fn test-move []
  (let [s (list-nav.make-state 10 5)]
    (list-nav.move s 3)
    (faith.= 4 s.cursor)
    (list-nav.move s -2)
    (faith.= 2 s.cursor)))

(fn test-goto []
  (let [s (list-nav.make-state 10 5)]
    (list-nav.goto s 7)
    (faith.= 7 s.cursor)))

(fn test-page-down []
  (let [s (list-nav.make-state 20 10)]
    (list-nav.page-down s)
    (faith.= 6 s.cursor)))

(fn test-page-up []
  (let [s (list-nav.make-state 20 10)]
    (list-nav.goto s 15)
    (list-nav.page-up s)
    (faith.= 10 s.cursor)))

(fn test-handle-key-up []
  (let [s (list-nav.make-state 10 5)]
    (list-nav.goto s 5)
    (faith.= true (list-nav.handle-key s "up"))
    (faith.= 4 s.cursor)))

(fn test-handle-key-down []
  (let [s (list-nav.make-state 10 5)]
    (faith.= true (list-nav.handle-key s "down"))
    (faith.= 2 s.cursor)))

(fn test-handle-key-k []
  (let [s (list-nav.make-state 10 5)]
    (list-nav.goto s 5)
    (faith.= true (list-nav.handle-key s "k"))
    (faith.= 4 s.cursor)))

(fn test-handle-key-j []
  (let [s (list-nav.make-state 10 5)]
    (faith.= true (list-nav.handle-key s "j"))
    (faith.= 2 s.cursor)))

(fn test-handle-key-ctrl-p []
  (let [s (list-nav.make-state 10 5)]
    (list-nav.goto s 5)
    (faith.= true (list-nav.handle-key s "\016"))
    (faith.= 4 s.cursor)))

(fn test-handle-key-ctrl-n []
  (let [s (list-nav.make-state 10 5)]
    (faith.= true (list-nav.handle-key s "\014"))
    (faith.= 2 s.cursor)))

(fn test-handle-key-g []
  (let [s (list-nav.make-state 10 5)]
    (list-nav.goto s 5)
    (faith.= true (list-nav.handle-key s "g"))
    (faith.= 1 s.cursor)))

(fn test-handle-key-G []
  (let [s (list-nav.make-state 10 5)]
    (faith.= true (list-nav.handle-key s "G"))
    (faith.= 10 s.cursor)))

(fn test-handle-key-unknown []
  (let [s (list-nav.make-state 10 5)]
    (faith.= false (list-nav.handle-key s "x"))
    (faith.= 1 s.cursor)))

(fn test-handle-key-typable-excludes-letters []
  (let [s (list-nav.make-state 10 5)]
    ;; k/j/g/G should NOT be handled (user is typing)
    (faith.= false (list-nav.handle-key-typable s "k"))
    (faith.= false (list-nav.handle-key-typable s "j"))
    (faith.= false (list-nav.handle-key-typable s "g"))
    (faith.= false (list-nav.handle-key-typable s "G"))))

(fn test-handle-key-typable-arrow-keys []
  (let [s (list-nav.make-state 10 5)]
    (faith.= true (list-nav.handle-key-typable s "down"))
    (faith.= 2 s.cursor)
    (faith.= true (list-nav.handle-key-typable s "up"))
    (faith.= 1 s.cursor)))

(fn test-set-n []
  (let [s (list-nav.make-state 10 5)]
    (list-nav.set-n s 20)
    (faith.= 20 s.n)))

(fn test-set-height []
  (let [s (list-nav.make-state 10 5)]
    (list-nav.set-height s 8)
    (faith.= 8 s.height)))

{:test-clamp-cursor-above-max test-clamp-cursor-above-max
 :test-clamp-cursor-below-min test-clamp-cursor-below-min
 :test-clamp-offset-scroll-down test-clamp-offset-scroll-down
 :test-clamp-offset-scroll-up test-clamp-offset-scroll-up
 :test-each-visible-iterates test-each-visible-iterates
 :test-each-visible-with-offset test-each-visible-with-offset
 :test-goto test-goto
 :test-handle-key-G test-handle-key-G
 :test-handle-key-ctrl-n test-handle-key-ctrl-n
 :test-handle-key-ctrl-p test-handle-key-ctrl-p
 :test-handle-key-down test-handle-key-down
 :test-handle-key-g test-handle-key-g
 :test-handle-key-j test-handle-key-j
 :test-handle-key-k test-handle-key-k
 :test-handle-key-typable-arrow-keys test-handle-key-typable-arrow-keys
 :test-handle-key-typable-excludes-letters test-handle-key-typable-excludes-letters
 :test-handle-key-unknown test-handle-key-unknown
 :test-handle-key-up test-handle-key-up
 :test-make-state test-make-state
 :test-move test-move
 :test-page-down test-page-down
 :test-page-up test-page-up
 :test-set-height test-set-height
 :test-set-n test-set-n
 :test-visible-height-full test-visible-height-full
 :test-visible-height-min-one test-visible-height-min-one
 :test-visible-height-truncates-to-n test-visible-height-truncates-to-n}
