(local ansi (require "vtx.ansi"))

(local write-m (require "vtx.widget.write"))

(local faith (require "faith"))

(fn test-utf8-start-ascii []
  (faith.= 1 (write-m.utf8-codepoint-start "a" 1)))

(fn test-utf8-start-2byte-first []
  (faith.= 1 (write-m.utf8-codepoint-start "é" 1)))

(fn test-utf8-start-2byte-continuation []
  (faith.= 1 (write-m.utf8-codepoint-start "é" 2)))

(fn test-utf8-start-3byte-continuation []
  (faith.= 1 (write-m.utf8-codepoint-start "─" 3)))

(fn test-utf8-next-ascii []
  (faith.= 1 (write-m.utf8-next-pos "a" 0)))

(fn test-utf8-next-2byte []
  (faith.= 2 (write-m.utf8-next-pos "é" 0)))

(fn test-utf8-next-3byte []
  (faith.= 3 (write-m.utf8-next-pos "─" 0)))

(fn test-utf8-next-eos []
  (faith.= 1 (write-m.utf8-next-pos "a" 1)))

(fn test-cursor-char-mid []
  (let [s (ansi.strip (write-m.cursor-char "hello" 2 ansi.fg.green))]
    (faith.= "l" s)))

(fn test-cursor-char-end []
  (let [s (ansi.strip (write-m.cursor-char "hi" 2 ansi.fg.green))]
    (faith.= " " s)))

(fn test-cursor-char-has-ansi []
  (let [s (write-m.cursor-char "x" 0 ansi.fg.green)]
    (faith.is (: s "find" "\027" 1 true))))

(fn test-render-line-non-cursor []
  (faith.= "hello" (write-m.render-line "hello" 0 false {})))

(fn test-render-line-cursor []
  (let [s (write-m.render-line "hello" 2 true {:cursor-fg ansi.fg.green})
        stripped (ansi.strip s)]
    (faith.= "hello" stripped)))

(fn test-render-line-cursor-has-ansi []
  (let [s (write-m.render-line "abc" 1 true {:cursor-fg ansi.fg.green})]
    (faith.is (: s "find" "\027" 1 true))))

{:test-cursor-char-end test-cursor-char-end
 :test-cursor-char-has-ansi test-cursor-char-has-ansi
 :test-cursor-char-mid test-cursor-char-mid
 :test-render-line-cursor test-render-line-cursor
 :test-render-line-cursor-has-ansi test-render-line-cursor-has-ansi
 :test-render-line-non-cursor test-render-line-non-cursor
 :test-utf8-next-2byte test-utf8-next-2byte
 :test-utf8-next-3byte test-utf8-next-3byte
 :test-utf8-next-ascii test-utf8-next-ascii
 :test-utf8-next-eos test-utf8-next-eos
 :test-utf8-start-2byte-continuation test-utf8-start-2byte-continuation
 :test-utf8-start-2byte-first test-utf8-start-2byte-first
 :test-utf8-start-3byte-continuation test-utf8-start-3byte-continuation
 :test-utf8-start-ascii test-utf8-start-ascii}
