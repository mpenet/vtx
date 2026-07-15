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

(fn len [s]
  (let [s2 (strip s)]
    (# (s2:gsub "[\128-\191]" ""))))

(fn style [text & attrs]
  (if (= (# attrs) 0)
      text
      (.. (table.concat attrs "") text reset)))

{:bg bg
 :bg-rgb bg-rgb
 :bg256 bg256
 :blink blink
 :blink-off blink-off
 :bold bold
 :bold-off bold-off
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
 :underline-off underline-off}
