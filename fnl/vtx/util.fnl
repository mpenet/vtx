(local ansi (require "vtx.ansi"))

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
      (table.insert lines line))
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
 :wrap wrap}
