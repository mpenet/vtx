(local ansi (require "vtx.ansi"))

(local string-rep string.rep)

(fn utf8-codepoint-start [s pos]
  (var p pos)
  (while (and (> p 1) (let [b (string.byte s p)]
                        (and (>= b 128) (<= b 191))))
    (set p (- p 1)))
  p)

(fn utf8-next-pos [s pos]
  (let [b (string.byte s (+ pos 1))]
    (if (not b)
        pos
        (< b 192)
        (+ pos 1)
        (< b 224)
        (+ pos 2)
        (< b 240)
        (+ pos 3)
        (+ pos 4))))

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
              (let [(cp char-len) (ansi.utf8-codepoint s i)
                    cw (ansi.codepoint-width cp)]
                (if (<= (+ vw cw) (- max-w 1))
                    (do
                      (table.insert result (s:sub i (+ i char-len -1)))
                      (set vw (+ vw cw))
                      (set i (+ i char-len)))
                    (do
                      (when (= cw 2)
                        (table.insert result " "))
                      (set i (+ slen 1)))))))
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
      (let [stripped (if (and (> (# line) 0) (= (line:sub -1) "\r"))
                         (line:sub 1 -2)
                         line)]
        (table.insert lines stripped)))
    (when (and (> (# lines) 0) (= (. lines (# lines)) ""))
      (table.remove lines))
    (if (= (# lines) 0)
        [""]
        lines)))

(fn wrap [text width]
  (if (<= width 0)
      text
      (let [result {}
            lines (split-lines text)]
        (each [_ line (ipairs lines)]
          (let [words {}]
            (each [w (line:gmatch "%S+")]
              (table.insert words w))
            (if (= (# words) 0)
                (table.insert result "")
                (do
                  (var cur "")
                  (var cur-w 0)
                  (each [_ word (ipairs words)]
                    (let [ww (ansi.len word)]
                      (if (= cur-w 0)
                          (do
                            (set cur word)
                            (set cur-w ww))
                          (if (<= (+ cur-w 1 ww) width)
                              (do
                                (set cur (.. cur " " word))
                                (set cur-w (+ cur-w 1 ww)))
                              (do
                                (table.insert result cur)
                                (set cur word)
                                (set cur-w ww))))))
                  (table.insert result cur)))))
        (table.concat result "\n"))))

{:clipboard-copy clipboard-copy
 :clipboard-paste clipboard-paste
 :split-lines split-lines
 :string-rep string-rep
 :trunc trunc
 :utf8-codepoint-start utf8-codepoint-start
 :utf8-next-pos utf8-next-pos
 :wrap wrap}
