(local ansi (require "vtx.ansi"))

(local faith (require "faith"))

(fn test-len-empty []
  (faith.= 0 (ansi.len "")))

(fn test-len-ascii []
  (faith.= 5 (ansi.len "hello")))

(fn test-len-single []
  (faith.= 1 (ansi.len "x")))

(fn test-len-space []
  (faith.= 1 (ansi.len " ")))

(fn test-len-styled []
  (faith.= 5 (ansi.len (ansi.style "hello" ansi.bold))))

(fn test-len-multi-attr []
  (faith.= 2 (ansi.len (ansi.style "hi" ansi.bold ansi.fg.red ansi.italic))))

(fn test-len-ansi-only []
  (faith.= 0 (ansi.len ansi.bold)))

(fn test-len-ansi-only-reset []
  (faith.= 0 (ansi.len ansi.reset)))

(fn test-len-ansi-only-multi []
  (faith.= 0 (ansi.len (.. ansi.bold ansi.fg.red ansi.reset))))

(fn test-len-utf8-box []
  (faith.= 1 (ansi.len "─")))

(fn test-len-utf8-box-x4 []
  (faith.= 4 (ansi.len "────")))

(fn test-len-utf8-box-x10 []
  (faith.= 10 (ansi.len "──────────")))

(fn test-len-utf8-corners []
  (faith.= 4 (ansi.len "╭──╮")))

(fn test-len-utf8-corner []
  (faith.= 1 (ansi.len "╭")))

(fn test-len-ansi-utf8 []
  (faith.= 1 (ansi.len (ansi.style "─" ansi.fg.red))))

(fn test-len-mixed []
  (faith.= 8 (ansi.len (.. "abc" (ansi.style "de" ansi.bold) "fgh"))))

(fn test-strip-plain []
  (faith.= "hello" (ansi.strip "hello")))

(fn test-strip-empty []
  (faith.= "" (ansi.strip "")))

(fn test-strip-bold []
  (faith.= "hi" (ansi.strip (ansi.style "hi" ansi.bold))))

(fn test-strip-fg []
  (faith.= "hi" (ansi.strip (ansi.style "hi" ansi.fg.red))))

(fn test-strip-multi []
  (faith.= "hi" (ansi.strip (ansi.style "hi" ansi.bold ansi.fg.cyan))))

(fn test-strip-dim []
  (faith.= "text" (ansi.strip (ansi.style "text" ansi.dim))))

(fn test-strip-ansi-only []
  (faith.= "" (ansi.strip ansi.bold)))

(fn test-strip-consecutive []
  (faith.= "ab" (ansi.strip (.. ansi.bold "a" ansi.fg.red "b" ansi.reset))))

(fn test-strip-utf8-preserved []
  (faith.= "──" (ansi.strip (ansi.style "──" ansi.fg.cyan))))

(fn test-strip-cursor-up []
  (faith.= "hi" (ansi.strip (.. "\027[3A" "hi"))))

(fn test-strip-cursor-down []
  (faith.= "hi" (ansi.strip (.. "\027[2B" "hi"))))

(fn test-strip-cursor-col []
  (faith.= "hi" (ansi.strip (.. "\027[10G" "hi"))))

(fn test-strip-clear-right []
  (faith.= "hi" (ansi.strip (.. "hi" "\027[0K"))))

(fn test-strip-mixed-motion-and-color []
  (faith.= "ab" (ansi.strip (.. "\027[1A" "\027[32m" "a" "\027[5A" "\027[0m" "b"))))

(fn test-style-no-attrs []
  (faith.= "x" (ansi.style "x")))

(fn test-style-stripped-eq []
  (faith.= "hello world" (ansi.strip (ansi.style "hello world" ansi.bold ansi.fg.cyan))))

(fn test-style-contains-esc []
  (faith.is (: (ansi.style "x" ansi.bold) "find" "\027")))

(fn test-style-starts-with-attr []
  (faith.is (: (ansi.style "x" ansi.bold) "find" "^\027")))

(fn test-style-ends-with-reset []
  (let [s (ansi.style "x" ansi.bold)]
    (faith.= ansi.reset (s:sub (- (# s) (# ansi.reset) -1)))))

(fn test-style-empty-text []
  (faith.= "" (ansi.strip (ansi.style "" ansi.bold))))

(fn test-bold []
  (faith.= "\027[1m" ansi.bold))

(fn test-dim []
  (faith.= "\027[2m" ansi.dim))

(fn test-italic []
  (faith.= "\027[3m" ansi.italic))

(fn test-underline []
  (faith.= "\027[4m" ansi.underline))

(fn test-blink []
  (faith.= "\027[5m" ansi.blink))

(fn test-reverse []
  (faith.= "\027[7m" ansi.reverse))

(fn test-hidden []
  (faith.= "\027[8m" ansi.hidden))

(fn test-strikethrough []
  (faith.= "\027[9m" ansi.strikethrough))

(fn test-bold-off []
  (faith.= "\027[22m" ansi.bold-off))

(fn test-italic-off []
  (faith.= "\027[23m" ansi.italic-off))

(fn test-underline-off []
  (faith.= "\027[24m" ansi.underline-off))

(fn test-blink-off []
  (faith.= "\027[25m" ansi.blink-off))

(fn test-reverse-off []
  (faith.= "\027[27m" ansi.reverse-off))

(fn test-reset []
  (faith.= "\027[0m" ansi.reset))

(fn test-fg-black []
  (faith.= "\027[30m" ansi.fg.black))

(fn test-fg-red []
  (faith.= "\027[31m" ansi.fg.red))

(fn test-fg-green []
  (faith.= "\027[32m" ansi.fg.green))

(fn test-fg-yellow []
  (faith.= "\027[33m" ansi.fg.yellow))

(fn test-fg-blue []
  (faith.= "\027[34m" ansi.fg.blue))

(fn test-fg-magenta []
  (faith.= "\027[35m" ansi.fg.magenta))

(fn test-fg-cyan []
  (faith.= "\027[36m" ansi.fg.cyan))

(fn test-fg-white []
  (faith.= "\027[37m" ansi.fg.white))

(fn test-fg-default []
  (faith.= "\027[39m" ansi.fg.default))

(fn test-fg-bright-black []
  (faith.= "\027[90m" ansi.fg.bright-black))

(fn test-fg-bright-red []
  (faith.= "\027[91m" ansi.fg.bright-red))

(fn test-fg-bright-green []
  (faith.= "\027[92m" ansi.fg.bright-green))

(fn test-fg-bright-yellow []
  (faith.= "\027[93m" ansi.fg.bright-yellow))

(fn test-fg-bright-blue []
  (faith.= "\027[94m" ansi.fg.bright-blue))

(fn test-fg-bright-magenta []
  (faith.= "\027[95m" ansi.fg.bright-magenta))

(fn test-fg-bright-cyan []
  (faith.= "\027[96m" ansi.fg.bright-cyan))

(fn test-fg-bright-white []
  (faith.= "\027[97m" ansi.fg.bright-white))

(fn test-bg-black []
  (faith.= "\027[40m" ansi.bg.black))

(fn test-bg-red []
  (faith.= "\027[41m" ansi.bg.red))

(fn test-bg-green []
  (faith.= "\027[42m" ansi.bg.green))

(fn test-bg-yellow []
  (faith.= "\027[43m" ansi.bg.yellow))

(fn test-bg-blue []
  (faith.= "\027[44m" ansi.bg.blue))

(fn test-bg-magenta []
  (faith.= "\027[45m" ansi.bg.magenta))

(fn test-bg-cyan []
  (faith.= "\027[46m" ansi.bg.cyan))

(fn test-bg-white []
  (faith.= "\027[47m" ansi.bg.white))

(fn test-bg-default []
  (faith.= "\027[49m" ansi.bg.default))

(fn test-bg-bright-red []
  (faith.= "\027[101m" ansi.bg.bright-red))

(fn test-bg-bright-green []
  (faith.= "\027[102m" ansi.bg.bright-green))

(fn test-fg256 []
  (faith.= "\027[38;5;196m" (ansi.fg256 196)))

(fn test-fg256-zero []
  (faith.= "\027[38;5;0m" (ansi.fg256 0)))

(fn test-fg256-max []
  (faith.= "\027[38;5;255m" (ansi.fg256 255)))

(fn test-bg256 []
  (faith.= "\027[48;5;196m" (ansi.bg256 196)))

(fn test-fg-rgb []
  (faith.= "\027[38;2;255;0;128m" (ansi.fg-rgb 255 0 128)))

(fn test-fg-rgb-zeros []
  (faith.= "\027[38;2;0;0;0m" (ansi.fg-rgb 0 0 0)))

(fn test-bg-rgb []
  (faith.= "\027[48;2;0;128;255m" (ansi.bg-rgb 0 128 255)))

(fn test-cursor-up-1 []
  (faith.= "\027[1A" (ansi.cursor.up 1)))

(fn test-cursor-up-5 []
  (faith.= "\027[5A" (ansi.cursor.up 5)))

(fn test-cursor-up-default []
  (faith.= "\027[1A" (ansi.cursor.up)))

(fn test-cursor-down []
  (faith.= "\027[3B" (ansi.cursor.down 3)))

(fn test-cursor-right []
  (faith.= "\027[2C" (ansi.cursor.right 2)))

(fn test-cursor-left []
  (faith.= "\027[4D" (ansi.cursor.left 4)))

(fn test-cursor-col []
  (faith.= "\027[10G" (ansi.cursor.col 10)))

(fn test-cursor-pos []
  (faith.= "\027[3;7H" (ansi.cursor.pos 3 7)))

(fn test-cursor-pos-origin []
  (faith.= "\027[1;1H" (ansi.cursor.pos 1 1)))

(fn test-cursor-hide []
  (faith.= "\027[?25l" ansi.cursor.hide))

(fn test-cursor-show []
  (faith.= "\027[?25h" ansi.cursor.show))

(fn test-cursor-save []
  (faith.= "\027[s" ansi.cursor.save))

(fn test-cursor-restore []
  (faith.= "\027[u" ansi.cursor.restore))

(fn test-screen-clear-right []
  (faith.= "\027[0K" ansi.screen.clear-right))

(fn test-screen-clear-left []
  (faith.= "\027[1K" ansi.screen.clear-left))

(fn test-screen-clear-line []
  (faith.= "\027[2K" ansi.screen.clear-line))

(fn test-screen-clear []
  (faith.= "\027[2J" ansi.screen.clear))

(fn test-screen-home []
  (faith.= "\027[H" ansi.screen.home))

(fn test-screen-alt-on []
  (faith.= "\027[?1049h" ansi.screen.alt-on))

(fn test-screen-alt-off []
  (faith.= "\027[?1049l" ansi.screen.alt-off))

(fn test-utf8-codepoint-ascii []
  (let [(cp cl) (ansi.utf8-codepoint "A" 1)]
    (faith.= 65 cp)
    (faith.= 1 cl)))

(fn test-utf8-codepoint-2byte []
  (let [(cp cl) (ansi.utf8-codepoint "é" 1)]
    (faith.= 233 cp)
    (faith.= 2 cl)))

(fn test-utf8-codepoint-3byte []
  (let [(cp cl) (ansi.utf8-codepoint "中" 1)]
    (faith.= 20013 cp)
    (faith.= 3 cl)))

(fn test-utf8-codepoint-offset []
  (let [(cp cl) (ansi.utf8-codepoint "A中" 2)]
    (faith.= 20013 cp)
    (faith.= 3 cl)))

(fn test-codepoint-width-ascii []
  (faith.= 1 (ansi.codepoint-width 65)))

(fn test-codepoint-width-space []
  (faith.= 1 (ansi.codepoint-width 32)))

(fn test-codepoint-width-control []
  (faith.= 0 (ansi.codepoint-width 27)))

(fn test-codepoint-width-nul []
  (faith.= 0 (ansi.codepoint-width 0)))

(fn test-codepoint-width-combining []
  (faith.= 0 (ansi.codepoint-width 768)))

(fn test-codepoint-width-cjk []
  (faith.= 2 (ansi.codepoint-width 20013)))

(fn test-codepoint-width-hangul []
  (faith.= 2 (ansi.codepoint-width 44032)))

(fn test-codepoint-width-box []
  (faith.= 1 (ansi.codepoint-width 9472)))

(fn test-len-wide-single []
  (faith.= 2 (ansi.len "中")))

(fn test-len-wide-two []
  (faith.= 4 (ansi.len "中文")))

(fn test-len-wide-mixed []
  (faith.= 3 (ansi.len "A中")))

(fn test-len-wide-styled []
  (faith.= 2 (ansi.len (ansi.style "中" ansi.bold))))

{:test-bg-black test-bg-black
 :test-bg-blue test-bg-blue
 :test-bg-bright-green test-bg-bright-green
 :test-bg-bright-red test-bg-bright-red
 :test-bg-cyan test-bg-cyan
 :test-bg-default test-bg-default
 :test-bg-green test-bg-green
 :test-bg-magenta test-bg-magenta
 :test-bg-red test-bg-red
 :test-bg-rgb test-bg-rgb
 :test-bg-white test-bg-white
 :test-bg-yellow test-bg-yellow
 :test-bg256 test-bg256
 :test-blink test-blink
 :test-blink-off test-blink-off
 :test-bold test-bold
 :test-bold-off test-bold-off
 :test-codepoint-width-ascii test-codepoint-width-ascii
 :test-codepoint-width-box test-codepoint-width-box
 :test-codepoint-width-cjk test-codepoint-width-cjk
 :test-codepoint-width-combining test-codepoint-width-combining
 :test-codepoint-width-control test-codepoint-width-control
 :test-codepoint-width-hangul test-codepoint-width-hangul
 :test-codepoint-width-nul test-codepoint-width-nul
 :test-codepoint-width-space test-codepoint-width-space
 :test-cursor-col test-cursor-col
 :test-cursor-down test-cursor-down
 :test-cursor-hide test-cursor-hide
 :test-cursor-left test-cursor-left
 :test-cursor-pos test-cursor-pos
 :test-cursor-pos-origin test-cursor-pos-origin
 :test-cursor-restore test-cursor-restore
 :test-cursor-right test-cursor-right
 :test-cursor-save test-cursor-save
 :test-cursor-show test-cursor-show
 :test-cursor-up-1 test-cursor-up-1
 :test-cursor-up-5 test-cursor-up-5
 :test-cursor-up-default test-cursor-up-default
 :test-dim test-dim
 :test-fg-black test-fg-black
 :test-fg-blue test-fg-blue
 :test-fg-bright-black test-fg-bright-black
 :test-fg-bright-blue test-fg-bright-blue
 :test-fg-bright-cyan test-fg-bright-cyan
 :test-fg-bright-green test-fg-bright-green
 :test-fg-bright-magenta test-fg-bright-magenta
 :test-fg-bright-red test-fg-bright-red
 :test-fg-bright-white test-fg-bright-white
 :test-fg-bright-yellow test-fg-bright-yellow
 :test-fg-cyan test-fg-cyan
 :test-fg-default test-fg-default
 :test-fg-green test-fg-green
 :test-fg-magenta test-fg-magenta
 :test-fg-red test-fg-red
 :test-fg-rgb test-fg-rgb
 :test-fg-rgb-zeros test-fg-rgb-zeros
 :test-fg-white test-fg-white
 :test-fg-yellow test-fg-yellow
 :test-fg256 test-fg256
 :test-fg256-max test-fg256-max
 :test-fg256-zero test-fg256-zero
 :test-hidden test-hidden
 :test-italic test-italic
 :test-italic-off test-italic-off
 :test-len-ansi-only test-len-ansi-only
 :test-len-ansi-only-multi test-len-ansi-only-multi
 :test-len-ansi-only-reset test-len-ansi-only-reset
 :test-len-ansi-utf8 test-len-ansi-utf8
 :test-len-ascii test-len-ascii
 :test-len-empty test-len-empty
 :test-len-mixed test-len-mixed
 :test-len-multi-attr test-len-multi-attr
 :test-len-single test-len-single
 :test-len-space test-len-space
 :test-len-styled test-len-styled
 :test-len-utf8-box test-len-utf8-box
 :test-len-utf8-box-x10 test-len-utf8-box-x10
 :test-len-utf8-box-x4 test-len-utf8-box-x4
 :test-len-utf8-corner test-len-utf8-corner
 :test-len-utf8-corners test-len-utf8-corners
 :test-len-wide-mixed test-len-wide-mixed
 :test-len-wide-single test-len-wide-single
 :test-len-wide-styled test-len-wide-styled
 :test-len-wide-two test-len-wide-two
 :test-reset test-reset
 :test-reverse test-reverse
 :test-reverse-off test-reverse-off
 :test-screen-alt-off test-screen-alt-off
 :test-screen-alt-on test-screen-alt-on
 :test-screen-clear test-screen-clear
 :test-screen-clear-left test-screen-clear-left
 :test-screen-clear-line test-screen-clear-line
 :test-screen-clear-right test-screen-clear-right
 :test-screen-home test-screen-home
 :test-strikethrough test-strikethrough
 :test-strip-ansi-only test-strip-ansi-only
 :test-strip-bold test-strip-bold
 :test-strip-clear-right test-strip-clear-right
 :test-strip-consecutive test-strip-consecutive
 :test-strip-cursor-col test-strip-cursor-col
 :test-strip-cursor-down test-strip-cursor-down
 :test-strip-cursor-up test-strip-cursor-up
 :test-strip-dim test-strip-dim
 :test-strip-empty test-strip-empty
 :test-strip-fg test-strip-fg
 :test-strip-mixed-motion-and-color test-strip-mixed-motion-and-color
 :test-strip-multi test-strip-multi
 :test-strip-plain test-strip-plain
 :test-strip-utf8-preserved test-strip-utf8-preserved
 :test-style-contains-esc test-style-contains-esc
 :test-style-empty-text test-style-empty-text
 :test-style-ends-with-reset test-style-ends-with-reset
 :test-style-no-attrs test-style-no-attrs
 :test-style-starts-with-attr test-style-starts-with-attr
 :test-style-stripped-eq test-style-stripped-eq
 :test-underline test-underline
 :test-underline-off test-underline-off
 :test-utf8-codepoint-2byte test-utf8-codepoint-2byte
 :test-utf8-codepoint-3byte test-utf8-codepoint-3byte
 :test-utf8-codepoint-ascii test-utf8-codepoint-ascii
 :test-utf8-codepoint-offset test-utf8-codepoint-offset}
