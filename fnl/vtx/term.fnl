(local posix (require "vtx.posix"))

(local ansi (require "vtx.ansi"))

(fn read-byte []
  (posix.read-byte))

(fn read-csi []
  (let [buf {}]
    (var done false)
    (while (not done)
      (let [c (read-byte)]
        (if (not c)
            (set done true)
            (do
              (table.insert buf c)
              (when (c:match "[A-Za-z~]")
                (set done true))))))
    (table.concat buf)))

(fn read-paste-content []
  (let [buf {}]
    (var done false)
    (while (not done)
      (let [c (read-byte)]
        (if (not c)
            (set done true)
            (= c "\027")
            (let [n1 (read-byte)]
              (if (= n1 "[")
                  (let [n2 (read-byte)
                        n3 (read-byte)
                        n4 (read-byte)
                        n5 (read-byte)]
                    (if (and (= n2 "2") (= n3 "0") (= n4 "1") (= n5 "~"))
                        (set done true)
                        (do
                          (table.insert buf c)
                          (when n1
                            (table.insert buf n1))
                          (when n2
                            (table.insert buf n2))
                          (when n3
                            (table.insert buf n3))
                          (when n4
                            (table.insert buf n4))
                          (when n5
                            (table.insert buf n5)))))
                  (do
                    (table.insert buf c)
                    (when n1
                      (table.insert buf n1)))))
            (table.insert buf c))))
    (table.concat buf)))

(fn read-key []
  (let [ch (read-byte)]
    (if (not ch)
        (if (posix.resized?)
            "resize"
            nil)
        (= ch "\027")
        (let [next (read-byte)]
          (if (or (not next) (= next ""))
              "escape"
              (= next "[")
              (match (read-csi)
                "A" "up"
                "B" "down"
                "C" "right"
                "D" "left"
                "H" "home"
                "F" "end"
                "3~" "delete"
                "5~" "page-up"
                "6~" "page-down"
                "1;2A" "shift-up"
                "1;2B" "shift-down"
                "1;2C" "shift-right"
                "1;2D" "shift-left"
                "M" (let [b (read-byte)
                          x (read-byte)
                          y (read-byte)]
                      (if (and b x y)
                          {:button (- (string.byte b) 32)
                           :col (- (string.byte x) 32)
                           :mouse true
                           :row (- (string.byte y) 32)}
                          "mouse"))
                "200~" {:paste (read-paste-content)}
                x (let [(button col row action) (x:match "^<(%d+);(%d+);(%d+)([Mm])$")]
                    (if button
                        {:action
                         (if (= action "M")
                             "press"
                             "release")
                         :button
                         (tonumber button)
                         :col
                         (tonumber col)
                         :mouse
                         true
                         :row
                         (tonumber row)}
                        (.. "\027[" x))))
              (= next "O")
              (let [c (read-byte)]
                (match c
                  "P" "f1"
                  "Q" "f2"
                  "R" "f3"
                  "S" "f4"
                  _ (.. "\027O" (or c ""))))
              (= next "\027")
              "escape"
              (.. "\027" next)))
        ch)))

(fn write [s]
  (posix.write s))

(fn writeln [s]
  (write (.. s "\r
")))

(fn cursor-up [n]
  (when (> n 0)
    (write (ansi.cursor.up n))))

(fn cursor-down [n]
  (when (> n 0)
    (write (ansi.cursor.down n))))

(fn cursor-col [n]
  (write (ansi.cursor.col n)))

(fn clear-rows [n]
  (for [_ 1 n]
    (write (.. "\r" ansi.screen.clear-right "\r
")))
  (when (> n 0)
    (write (ansi.cursor.up n))))

(fn cursor-hide []
  (write ansi.cursor.hide))

(fn cursor-show []
  (write ansi.cursor.show))

(fn clear-line []
  (write ansi.screen.clear-line))

(fn clear-right []
  (write ansi.screen.clear-right))

(fn size []
  (posix.term-size))

(fn make-frame-cache []
  {:last nil})

(fn render-frame [cache render-fn]
  (let [buf {}
        push (fn [s]
               (table.insert buf s))
        _ (render-fn push)
        frame (table.concat buf)]
    (when (not= frame cache.last)
      (write frame)
      (set cache.last frame))))

(fn with-raw [f ?opts]
  (when (and ?opts ?opts.alt-screen)
    (write ansi.screen.alt-on)
    (write ansi.screen.clear)
    (write ansi.screen.home))
  (when (and ?opts ?opts.bracketed-paste)
    (write "\027[?2004h"))
  (when (and ?opts ?opts.mouse)
    (write "\027[?1000h")
    (write "\027[?1006h"))
  (let [saved (posix.stty-save)]
    (posix.raw-mode-enter)
    (let [(ok err) (pcall (fn []
                            (cursor-hide)
                            (f)))]
      (pcall cursor-show)
      (pcall posix.stty-restore saved)
      (when (and ?opts ?opts.mouse)
        (pcall write "\027[?1006l")
        (pcall write "\027[?1000l"))
      (when (and ?opts ?opts.bracketed-paste)
        (pcall write "\027[?2004l"))
      (when (and ?opts ?opts.alt-screen)
        (pcall write ansi.screen.alt-off))
      (when (not ok)
        (error err)))))

{:clear-line clear-line
 :clear-right clear-right
 :clear-rows clear-rows
 :cursor-col cursor-col
 :cursor-down cursor-down
 :cursor-hide cursor-hide
 :cursor-show cursor-show
 :cursor-up cursor-up
 :make-frame-cache make-frame-cache
 :read-byte read-byte
 :read-key read-key
 :render-frame render-frame
 :size size
 :with-raw with-raw
 :write write
 :writeln writeln}
