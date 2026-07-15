(local ansi (require "tiki.ansi"))

(local util (require "tiki.util"))

(local no-color (or (os.getenv "NO_COLOR") (os.getenv "NO_COLOUR")))

(fn hex->rgb [hex]
  (let [h (if (= (hex:sub 1 1) "#") (hex:sub 2) hex)
        n (# h)]
    (if (= n 3)
        {:b (* 17 (tonumber (h:sub 3 3) 16))
         :g (* 17 (tonumber (h:sub 2 2) 16))
         :r (* 17 (tonumber (h:sub 1 1) 16))}
        {:b (tonumber (h:sub 5 6) 16)
         :g (tonumber (h:sub 3 4) 16)
         :r (tonumber (h:sub 1 2) 16)})))

(fn lerp-color [c1 c2 t]
  {:b (math.floor (+ c1.b (* t (- c2.b c1.b))))
   :g (math.floor (+ c1.g (* t (- c2.g c1.g))))
   :r (math.floor (+ c1.r (* t (- c2.r c1.r))))})

(fn color-at [rgb-stops t]
  (let [n (# rgb-stops)]
    (if (<= n 1)
        (or (. rgb-stops 1) {:b 255 :g 255 :r 255})
        (>= t 1)
        (. rgb-stops n)
        (let [seg (* t (- n 1))
              i (math.floor seg)
              frac (- seg i)]
          (lerp-color (. rgb-stops (+ i 1)) (. rgb-stops (+ i 2)) frac)))))

(fn parse-stops [stops]
  (icollect [_ s (ipairs stops)] (hex->rgb s)))

(fn gradient-text [text stops]
  (if no-color
      text
      (let [rgb-stops (parse-stops stops)
            out {}
            slen (# text)
            vn (do
                 (var n 0)
                 (var i 1)
                 (while (<= i slen)
                   (let [(cp cl) (ansi.utf8-codepoint text i)]
                     (when (~= cp 10)
                       (set n (+ n 1)))
                     (set i (+ i cl))))
                 n)]
        (var vi 0)
        (var i 1)
        (while (<= i slen)
          (let [(cp cl) (ansi.utf8-codepoint text i)
                bytes (text:sub i (+ i cl -1))]
            (if (= cp 10)
                (table.insert out "\n")
                (do
                  (set vi (+ vi 1))
                  (let [t (if (<= vn 1) 0 (/ (- vi 1) (- vn 1)))
                        col (color-at rgb-stops t)]
                    (table.insert out (.. (ansi.fg-rgb col.r col.g col.b) bytes)))))
            (set i (+ i cl))))
        (.. (table.concat out) ansi.reset))))

(fn gradient-lines [text stops]
  (if no-color
      text
      (let [rgb-stops (parse-stops stops)
            lines (util.split-lines text)
            n (# lines)
            result {}]
        (for [i 1 n]
          (let [t (if (<= n 1) 0 (/ (- i 1) (- n 1)))
                col (color-at rgb-stops t)]
            (table.insert result (.. (ansi.fg-rgb col.r col.g col.b) (. lines i) ansi.reset))))
        (table.concat result "\n"))))

(fn gradient-bg-lines [text stops]
  (if no-color
      text
      (let [rgb-stops (parse-stops stops)
            lines (util.split-lines text)
            n (# lines)
            result {}]
        (for [i 1 n]
          (let [t (if (<= n 1) 0 (/ (- i 1) (- n 1)))
                col (color-at rgb-stops t)]
            (table.insert result (.. (ansi.bg-rgb col.r col.g col.b) (. lines i) ansi.reset))))
        (table.concat result "\n"))))

{:color-at color-at
 :gradient-bg-lines gradient-bg-lines
 :gradient-lines gradient-lines
 :gradient-text gradient-text
 :hex->rgb hex->rgb
 :lerp-color lerp-color
 :parse-stops parse-stops}
