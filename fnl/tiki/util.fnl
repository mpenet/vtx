(local ansi (require "tiki.ansi"))

(fn string-rep [s n]
  (let [t {}]
    (for [_ 1 n]
      (table.insert t s))
    (table.concat t)))

(fn trunc [s max-w]
  (if (<= (ansi.len s) max-w)
      s
      (let [result {}
            slen (# s)]
        (var i 1)
        (var vw 0)
        (while (and (<= i slen) (< vw (- max-w 1)))
          (if (= (s:sub i i) "\027")
              (let [j (s:find "[A-Za-z]" (+ i 1))]
                (if j
                    (do
                      (table.insert result (s:sub i j))
                      (set i (+ j 1)))
                    (set i (+ i 1))))
              (let [b (s:byte i)
                    char-len (if (< b 128)
                                 1
                                 (< b 224)
                                 2
                                 (< b 240)
                                 3
                                 4)]
                (table.insert result (s:sub i (+ i char-len -1)))
                (set vw (+ vw 1))
                (set i (+ i char-len)))))
        (.. (table.concat result) ansi.reset "…"))))

(fn clipboard-copy [text]
  (let [h (io.popen "(pbcopy || xclip -selection clipboard -i || xsel -ib) 2>/dev/null" "w")]
    (when h
      (h:write text)
      (h:close))))

(fn clipboard-paste []
  (let [h (io.popen "(pbpaste || xclip -selection clipboard -o || xsel -ob) 2>/dev/null")]
    (when h
      (let [out (h:read "*a")]
        (h:close)
        (if (and out (> (# out) 0))
            out
            nil)))))

(fn split-lines [s]
  (let [lines {}
        pat (.. "[^" (string.char 10) "]*")]
    (each [line (s:gmatch pat)]
      (table.insert lines line))
    (when (and (> (# lines) 0) (= (. lines (# lines)) ""))
      (table.remove lines))
    (if (= (# lines) 0)
        [""]
        lines)))

{:clipboard-copy clipboard-copy
 :clipboard-paste clipboard-paste
 :split-lines split-lines
 :string-rep string-rep
 :trunc trunc}
