(var tty-in nil)

(local (native-ok native) (pcall require "tiki.posix_native"))

(local native (if native-ok
                  native
                  nil))

(when native
  (native.setup_winch))

(fn tty-open []
  (when (not tty-in)
    (set tty-in (io.open "/dev/tty" "rb")))
  tty-in)

(fn tty-close []
  (when tty-in
    (tty-in:close)
    (set tty-in nil)))

(fn stty-save []
  (let [h (io.popen "stty -g < /dev/tty 2>/dev/null")]
    (when h
      (let [out (h:read "*l")]
        (h:close)
        out))))

(fn stty-restore [saved]
  (when (and saved (= (type saved) "string") (saved:match "^[%w:=/.-]+$"))
    (os.execute (.. "stty " saved " < /dev/tty 2>/dev/null"))))

(fn sleep [seconds]
  (if native
      (native.sleep seconds)
      (let [h (io.popen (.. "sleep " seconds " 2>/dev/null"))]
        (when h
          (h:close)))))

(fn raw-mode-enter []
  (os.execute "stty raw -echo -isig min 1 time 1 < /dev/tty 2>/dev/null"))

(fn read-byte []
  (let [f (tty-open)]
    (when f
      (f:read 1))))

(fn resized? []
  (if native
      (native.resized)
      false))

(fn write [s]
  (io.stdout:write s)
  (io.stdout:flush))

(fn term-size []
  (let [h (io.popen "stty size < /dev/tty 2>/dev/null")]
    (when h
      (let [out (h:read "*l")]
        (h:close)
        (when out
          (let [(rows cols) (out:match "(%d+) (%d+)")]
            (when (and rows cols)
              (values (tonumber rows) (tonumber cols)))))))))

{:STDERR_FILENO 2
 :STDIN_FILENO 0
 :STDOUT_FILENO 1
 :raw-mode-enter raw-mode-enter
 :read-byte read-byte
 :resized? resized?
 :sleep sleep
 :stty-restore stty-restore
 :stty-save stty-save
 :term-size term-size
 :tty-close tty-close
 :tty-open tty-open
 :write write}
