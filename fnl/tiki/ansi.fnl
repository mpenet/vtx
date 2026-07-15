(fn esc [& codes]
  (.. "\027[" (table.concat codes ";") "m"))

(local reset (esc 0))

(local bold (esc 1))

(local dim (esc 2))

(local italic (esc 3))

(local underline (esc 4))

(local blink (esc 5))

(local reverse (esc 7))

(local hidden (esc 8))

(local strikethrough (esc 9))

(local bold-off (esc 22))

(local italic-off (esc 23))

(local underline-off (esc 24))

(local blink-off (esc 25))

(local reverse-off (esc 27))

(local fg {:black (esc 30)
           :blue (esc 34)
           :bright-black (esc 90)
           :bright-blue (esc 94)
           :bright-cyan (esc 96)
           :bright-green (esc 92)
           :bright-magenta (esc 95)
           :bright-red (esc 91)
           :bright-white (esc 97)
           :bright-yellow (esc 93)
           :cyan (esc 36)
           :default (esc 39)
           :green (esc 32)
           :magenta (esc 35)
           :red (esc 31)
           :white (esc 37)
           :yellow (esc 33)})

(local bg {:black (esc 40)
           :blue (esc 44)
           :bright-black (esc 100)
           :bright-blue (esc 104)
           :bright-cyan (esc 106)
           :bright-green (esc 102)
           :bright-magenta (esc 105)
           :bright-red (esc 101)
           :bright-white (esc 107)
           :bright-yellow (esc 103)
           :cyan (esc 46)
           :default (esc 49)
           :green (esc 42)
           :magenta (esc 45)
           :red (esc 41)
           :white (esc 47)
           :yellow (esc 43)})

(fn fg256 [n]
  (esc 38 5 n))

(fn bg256 [n]
  (esc 48 5 n))

(fn fg-rgb [r g b]
  (esc 38 2 r g b))

(fn bg-rgb [r g b]
  (esc 48 2 r g b))

(local cursor {:col
               (fn [n]
                 (.. "\027[" n "G"))
               :down
               (fn [n]
                 (.. "\027[" (or n 1) "B"))
               :hide
               "\027[?25l"
               :left
               (fn [n]
                 (.. "\027[" (or n 1) "D"))
               :pos
               (fn [row col]
                 (.. "\027[" row ";" col "H"))
               :restore
               "\027[u"
               :right
               (fn [n]
                 (.. "\027[" (or n 1) "C"))
               :save
               "\027[s"
               :show
               "\027[?25h"
               :up
               (fn [n]
                 (.. "\027[" (or n 1) "A"))})

(local screen {:alt-off "\027[?1049l"
               :alt-on "\027[?1049h"
               :clear "\027[2J"
               :clear-left "\027[1K"
               :clear-line "\027[2K"
               :clear-right "\027[0K"
               :home "\027[H"})

(fn strip [s]
  (s:gsub "\027%[[%d;]*m" ""))

;; Sorted [start end] pairs of Unicode codepoints that occupy 2 terminal columns
(local wide-ranges
  [[0x1100 0x115F]
   [0x2E80 0x33FF]
   [0x3400 0x9FFF]
   [0xA000 0xA4CF]
   [0xA960 0xA97F]
   [0xAC00 0xD7AF]
   [0xF900 0xFAFF]
   [0xFE10 0xFE6F]
   [0xFF01 0xFF60]
   [0xFFE0 0xFFE6]
   [0x1B000 0x1B2FB]
   [0x1F200 0x1F9FF]
   [0x1FA00 0x1FAF8]
   [0x20000 0x3FFFD]])

(fn wide? [cp]
  (var lo 1)
  (var hi (# wide-ranges))
  (var result false)
  (while (and (<= lo hi) (not result))
    (let [mid (math.floor (/ (+ lo hi) 2))
          r (. wide-ranges mid)]
      (if (< cp (. r 1))
          (set hi (- mid 1))
          (> cp (. r 2))
          (set lo (+ mid 1))
          (set result true))))
  result)

(fn utf8-codepoint [s i]
  (let [b (s:byte i)]
    (if (< b 128)
        (values b 1)
        (< b 224)
        (values (+ (* (- b 192) 64) (- (s:byte (+ i 1)) 128)) 2)
        (< b 240)
        (values (+ (* (- b 224) 4096)
                   (* (- (s:byte (+ i 1)) 128) 64)
                   (- (s:byte (+ i 2)) 128)) 3)
        (values (+ (* (- b 240) 262144)
                   (* (- (s:byte (+ i 1)) 128) 4096)
                   (* (- (s:byte (+ i 2)) 128) 64)
                   (- (s:byte (+ i 3)) 128)) 4))))

(fn codepoint-width [cp]
  (if (< cp 32) 0
      (< cp 127) 1
      (< cp 160) 0
      (and (>= cp 0x0300) (<= cp 0x036F)) 0
      (and (>= cp 0x1DC0) (<= cp 0x1DFF)) 0
      (and (>= cp 0x20D0) (<= cp 0x20FF)) 0
      (and (>= cp 0xFE20) (<= cp 0xFE2F)) 0
      (wide? cp) 2
      1))

(local no-color (or (os.getenv "NO_COLOR") (os.getenv "NO_COLOUR")))

(fn len [s]
  (let [s2 (strip s)
        slen (# s2)]
    (var i 1)
    (var w 0)
    (while (<= i slen)
      (let [(cp char-len) (utf8-codepoint s2 i)]
        (set w (+ w (codepoint-width cp)))
        (set i (+ i char-len))))
    w))

(fn style [text & attrs]
  (if (or no-color (= (# attrs) 0))
      text
      (.. (table.concat attrs "") text reset)))

{:bg bg
 :bg-rgb bg-rgb
 :bg256 bg256
 :blink blink
 :blink-off blink-off
 :bold bold
 :bold-off bold-off
 :codepoint-width codepoint-width
 :cursor cursor
 :dim dim
 :fg fg
 :fg-rgb fg-rgb
 :fg256 fg256
 :hidden hidden
 :italic italic
 :italic-off italic-off
 :len len
 :reset reset
 :reverse reverse
 :reverse-off reverse-off
 :screen screen
 :strikethrough strikethrough
 :strip strip
 :style style
 :underline underline
 :underline-off underline-off
 :utf8-codepoint utf8-codepoint}
