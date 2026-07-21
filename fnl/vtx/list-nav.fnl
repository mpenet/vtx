(fn make-state [n height]
  {:cursor 1 :height height :n n :offset 0})

(fn set-n [st n]
  (set st.n n))

(fn set-height [st height]
  (set st.height height))

(fn clamp [st]
  (let [safe-n (math.max 1 st.n)]
    (set st.cursor (math.max 1 (math.min st.cursor safe-n)))
    (let [h (math.min st.height safe-n)]
      (when (< st.cursor (+ st.offset 1))
        (set st.offset (- st.cursor 1)))
      (when (> st.cursor (+ st.offset h))
        (set st.offset (- st.cursor h))))))

(fn visible-height [st]
  (math.min st.height (math.max 1 st.n)))

(fn each-visible [st f]
  (let [h (visible-height st)]
    (for [row 1 h]
      (let [i (+ st.offset row)]
        (f row i (= i st.cursor))))))

(fn move [st delta]
  (set st.cursor (+ st.cursor delta)))

(fn goto [st i]
  (set st.cursor i))

(fn page-down [st]
  (set st.cursor (+ st.cursor (math.floor (/ st.height 2)))))

(fn page-up [st]
  (set st.cursor (- st.cursor (math.floor (/ st.height 2)))))

(fn handle-key [st k]
  (match k
    (where (or "up" "k" "\016")) (do (move st -1) true)
    (where (or "down" "j" "\014")) (do (move st 1) true)
    (where (or "\006" "page-down")) (do (page-down st) true)
    (where (or "\002" "page-up")) (do (page-up st) true)
    "g" (do (goto st 1) true)
    "G" (do (goto st st.n) true)
    _ false))

(fn handle-key-typable [st k]
  "Same as handle-key but omits `k`/`j`/`g`/`G` letter bindings (for widgets where user is typing)."
  (match k
    (where (or "up" "\016")) (do (move st -1) true)
    (where (or "down" "\014")) (do (move st 1) true)
    (where (or "\006" "page-down")) (do (page-down st) true)
    (where (or "\002" "page-up")) (do (page-up st) true)
    _ false))

{:clamp clamp
 :each-visible each-visible
 :goto goto
 :handle-key handle-key
 :handle-key-typable handle-key-typable
 :make-state make-state
 :move move
 :page-down page-down
 :page-up page-up
 :set-height set-height
 :set-n set-n
 :visible-height visible-height}
