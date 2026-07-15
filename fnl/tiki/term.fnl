(local posix (require "tiki.posix"))

(local ansi (require "tiki.ansi"))

(var saved-stty nil)

(fn raw-mode-enter []
  (set saved-stty (posix.stty-save))
  (posix.raw-mode-enter))

(fn raw-mode-exit []
  (posix.stty-restore saved-stty)
  (set saved-stty nil))

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
                x (.. "\027[" x))
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
  (write (ansi.cursor.up n)))

(fn cursor-down [n]
  (write (ansi.cursor.down n)))

(fn cursor-col [n]
  (write (ansi.cursor.col n)))

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

(fn with-raw [f ?opts]
  (when (and ?opts ?opts.alt-screen)
    (write ansi.screen.alt-on)
    (write ansi.screen.clear)
    (write ansi.screen.home))
  (let [saved (posix.stty-save)]
    (posix.raw-mode-enter)
    (let [(ok err) (pcall (fn []
                            (cursor-hide)
                            (f)))]
      (pcall cursor-show)
      (pcall posix.stty-restore saved)
      (when (and ?opts ?opts.alt-screen)
        (pcall write ansi.screen.alt-off))
      (when (not ok)
        (error err)))))

{:clear-line clear-line
 :clear-right clear-right
 :cursor-col cursor-col
 :cursor-down cursor-down
 :cursor-hide cursor-hide
 :cursor-show cursor-show
 :cursor-up cursor-up
 :raw-mode-enter raw-mode-enter
 :raw-mode-exit raw-mode-exit
 :read-byte read-byte
 :read-key read-key
 :size size
 :with-raw with-raw
 :write write
 :writeln writeln}
