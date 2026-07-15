# tiki

Terminal UI widgets for [Fennel](https://fennel-lang.org/), inspired by [gum](https://github.com/charmbracelet/gum).  
Targets PUC Lua 5.5, no C extensions required.

[![CI](https://github.com/mpenet/tiki/actions/workflows/ci.yml/badge.svg)](https://github.com/mpenet/tiki/actions/workflows/ci.yml)

---

## Requirements

- PUC Lua 5.5
- Fennel 1.6+
- Unix terminal with `/dev/tty` and `stty`

## Installation

Clone the repo and add `fnl/` to your Fennel path, or copy the `fnl/tiki/` tree into your project.

```makefile
FENNEL_FLAGS = --add-fennel-path "fnl/?.fnl" --add-fennel-path "fnl/?/init.fnl"
```

Then require the top-level module or individual widgets:

```fennel
(local tiki (require :tiki))             ; everything
(local {: input} (require :tiki.widget.input))  ; just input
```

## Quick start

```fennel
(local tiki (require :tiki))

(let [name (tiki.input {:prompt "Name: "})
      ok   (tiki.confirm "Continue?")]
  (when (and name ok)
    (print (.. "Hello, " name "!"))))
```

Run the bundled demo: `make demo`

---

## Widgets

All interactive widgets return `nil` if the user aborts (ctrl-c or escape where noted).  
Colors default to the active theme; pass explicit values to override.

### `tiki.input opts`

Single-line text editor. Returns the entered string or `nil`.

```fennel
(tiki.input {:prompt      "> "
             :placeholder "type here…"
             :value       "prefilled"
             :prompt-fg   tiki.ansi.fg.cyan
             :cursor-fg   tiki.ansi.fg.green})
```

| Option | Default | Description |
|--------|---------|-------------|
| `:prompt` | `"> "` | Prompt prefix |
| `:placeholder` | `""` | Dim hint shown when buffer is empty |
| `:value` | `""` | Initial buffer content |
| `:prompt-fg` | cyan | Prompt color |
| `:cursor-fg` | green | Cursor highlight color |

**Keys**

| Key | Action |
|-----|--------|
| enter | Submit |
| ctrl-c | Abort |
| ←/→ ctrl-b/f | Move cursor |
| home/end ctrl-a/e | Line start/end |
| alt-f/b | Word forward/back |
| backspace/ctrl-h | Delete char back |
| delete | Delete char forward |
| ctrl-w / alt-backspace | Delete word back |
| alt-d | Delete word forward |
| ctrl-k | Kill to end of line |
| ctrl-u | Clear line |
| ctrl-y | Paste from clipboard |
| ctrl-z | Undo last edit |

---

### `tiki.password opts`

Masked password input. Returns the string or `nil`.

```fennel
(tiki.password {:prompt "Password: " :mask "•"})

;; Confirm mode: prompts twice, returns nil if they don't match
(tiki.password {:confirm        true
                :confirm-prompt "Confirm: "})
```

| Option | Default | Description |
|--------|---------|-------------|
| `:prompt` | `"> "` | Prompt prefix |
| `:mask` | `"•"` | Character shown in place of each typed character |
| `:confirm` | `false` | When `true`, prompt twice and verify match |
| `:confirm-prompt` | `"Confirm: "` | Second prompt text (confirm mode) |
| `:prompt-fg` | cyan | Prompt color |
| `:cursor-fg` | green | Cursor highlight color |

**Keys:** same as `input` except no paste (ctrl-y), undo (ctrl-z), or word navigation.

---

### `tiki.confirm prompt opts`

Yes/No prompt. Returns `true`, `false`, or `nil` on abort.

```fennel
(tiki.confirm "Delete file?")
(tiki.confirm "Overwrite?" {:default false :affirmative "Yep" :negative "Nope"})
```

| Option | Default | Description |
|--------|---------|-------------|
| `:default` | `true` | Which option starts selected |
| `:affirmative` | `"Yes"` | Label for the truthy choice |
| `:negative` | `"No"` | Label for the falsy choice |
| `:prompt-fg` | cyan | Prompt color |
| `:selected-fg` | green | Selected option color |
| `:selected-attr` | bold | Extra attribute on selected option |
| `:unselected-fg` | white | Unselected option color |

**Keys**

| Key | Action |
|-----|--------|
| ←/→ h/l ctrl-b/f | Toggle |
| y | Select yes and confirm |
| n | Select no and confirm |
| enter | Confirm current selection |
| ctrl-c | Abort |

---

### `tiki.choose items opts`

Pick one item from a list (or multiple in multi mode). Returns the selected item, or a list of items in multi mode, or `nil`.

```fennel
(tiki.choose ["Fennel" "Clojure" "Lua"])
(tiki.choose items {:height 8 :multi true})
```

| Option | Default | Description |
|--------|---------|-------------|
| `:height` | `10` | Max visible rows |
| `:multi` | `false` | Enable multi-select |
| `:cursor` | `"> "` | Cursor string |
| `:cursor-fg` | cyan | Cursor color |
| `:selected-fg` | green | Highlighted item color |
| `:selected-attr` | bold | Extra attribute on highlighted item |
| `:unselected-fg` | white | Normal item color |

**Returns:** in single mode, the item directly; in multi mode, a list. If nothing is selected in multi mode and enter is pressed, returns `[cursor-item]`.

**Keys**

| Key | Action |
|-----|--------|
| ↑/↓ k/j | Move cursor |
| g/G | First/last item |
| ctrl-f/ctrl-b | Half-page down/up |
| space | Toggle selection (multi) |
| enter | Confirm |
| q/ctrl-c | Abort |

---

### `tiki.filter items opts`

Incremental fuzzy or substring search over a list. Returns `[item, ...]` or `nil`.

```fennel
(tiki.filter files {:fuzzy true :height 10})
(tiki.filter items {:multi true :prompt "search: "})
```

| Option | Default | Description |
|--------|---------|-------------|
| `:height` | `10` | Max visible rows |
| `:fuzzy` | `true` | Fuzzy match (false = substring) |
| `:multi` | `false` | Enable multi-select |
| `:prompt` | `"> "` | Search prompt |
| `:prompt-fg` | cyan | Prompt color |
| `:cursor` | `"> "` | Cursor string |
| `:cursor-fg` | cyan | Cursor color |
| `:match-fg` | yellow | Matched character highlight color |
| `:selected-fg` | green | Highlighted item color |
| `:selected-attr` | bold | Extra attribute on highlighted item |
| `:unselected-fg` | white | Normal item color |

**Keys**

| Key | Action |
|-----|--------|
| type | Filter items |
| ↑/↓ | Move cursor |
| tab | Toggle selection (multi) |
| enter | Confirm |
| backspace | Delete query char |
| ctrl-u | Clear query |
| ctrl-c/escape | Abort |

---

### `tiki.write opts`

Multi-line text editor. Returns the text string or `nil` on abort.

```fennel
(tiki.write {:header "Notes:"
             :height 8
             :value  "initial text"})
```

| Option | Default | Description |
|--------|---------|-------------|
| `:height` | `10` | Visible line count |
| `:prompt` | `"  "` | Per-line left margin string |
| `:header` | `nil` | Label printed above the editor |
| `:value` | `""` | Initial content |
| `:prompt-fg` | cyan | Prompt color |
| `:cursor-fg` | green | Cursor color |

**Keys:** all `input` keys, plus:

| Key | Action |
|-----|--------|
| ↑/↓ | Move between lines |
| enter | Insert newline |
| ctrl-d | Submit |
| ctrl-k / ctrl-v | Kill to end of line |

---

### `tiki.form fields opts`

Sequential form collecting multiple inputs. Returns `{key → value}` or `nil` if any field is aborted.

```fennel
(tiki.form
  [{:type :input    :key :name  :label "Full name"  :opts {:prompt "Name: "}}
   {:type :password :key :pass  :label "Password"   :opts {:confirm true}}
   {:type :confirm  :key :agree :label "Accept terms?"}
   {:type :write    :key :notes :label "Notes"       :opts {:height 5}}]
  {})
```

Each field is a table with:

| Field key | Description |
|-----------|-------------|
| `:type` | `"input"`, `"password"`, `"confirm"`, or `"write"` |
| `:key` | Key in the returned result table (falls back to `:label`, then `:type`) |
| `:label` | Optional header printed before the field |
| `:opts` | Options passed to the underlying widget |

| Form option | Default | Description |
|-------------|---------|-------------|
| `:label-fg` | cyan | Color for field labels |

---

### `tiki.spin f opts`

Animated spinner while a function runs. The function is wrapped in a coroutine; yield a string to update the title mid-run. Returns the function's return value (or errors on failure).

```fennel
(tiki.spin
  (fn []
    (do-work)
    "done!")
  {:title "Loading…" :spinner "dots"})

;; Update title mid-spin by yielding a string
(tiki.spin
  (fn []
    (coroutine.yield "Step 1…")
    (step-1)
    (coroutine.yield "Step 2…")
    (step-2)
    "finished")
  {:title "Working…"})
```

| Option | Default | Description |
|--------|---------|-------------|
| `:title` | `""` | Text shown next to the spinner |
| `:spinner` | `"dots"` | Spinner animation name |
| `:interval` | `80` | Frame delay in milliseconds |
| `:spinner-fg` | cyan | Spinner color |

Available spinners: `"dots"`, `"dots2"`, `"line"`, `"bounce"`, `"arrow"`.

> List all: `(each [name _ (pairs tiki.spinners)] (print name))`

---

### `tiki.progress f opts`

Determinate progress bar. Calls `f` with an `update` function. In determinate mode `update` takes `(value total)`; in indeterminate mode call it with no arguments to advance the bounce position.

```fennel
;; Determinate
(tiki.progress
  (fn [update]
    (for [i 1 100]
      (update i 100)
      (process-item i)))
  {:title "Processing…" :width 40})

;; Indeterminate bounce
(tiki.progress
  (fn [update]
    (while (not done?)
      (update)
      (do-chunk)))
  {:indeterminate true :title "Working…"})
```

| Option | Default | Description |
|--------|---------|-------------|
| `:title` | `""` | Label shown after the bar |
| `:width` | `40` | Bar width in characters |
| `:indeterminate` | `false` | Bounce animation instead of fill |
| `:fill` | `"█"` | Filled block character |
| `:empty` | `"░"` | Empty block character |
| `:block-size` | `4` | Bounce block width (indeterminate) |
| `:bar-fg` | green | Bar color |

---

### `tiki.pager text opts`

Scrollable text viewer with incremental search. Blocks until the user quits.

```fennel
(tiki.pager long-text)
(tiki.pager content {:height 30})
```

| Option | Default | Description |
|--------|---------|-------------|
| `:height` | terminal rows − 1 | Visible line count |

**Keys**

| Key | Action |
|-----|--------|
| ↑/↓ k/j | Scroll one line |
| space ctrl-f | Half-page down |
| ctrl-b | Half-page up |
| page-up/page-down | Full page up/down |
| g/G | Top/bottom |
| / | Enter search mode |
| n/N | Next/prev match |
| l | Toggle line numbers |
| q/ctrl-c | Quit |

In search mode: type to filter, enter to confirm, escape/ctrl-c to cancel.

---

### `tiki.tbl headers rows opts`

Scrollable table with optional row selection. Returns the selected row (as an array) or `nil`.

```fennel
(tiki.tbl
  ["Name" "Age" "City"]
  [["Alice" "30" "NYC"]
   ["Bob"   "25" "LA"]]
  {:height 10 :select true})
```

| Option | Default | Description |
|--------|---------|-------------|
| `:height` | `10` | Max visible rows |
| `:select` | `true` | Enable row selection |
| `:sep` | `"  "` | Column separator string |
| `:header-fg` | cyan | Header row color |
| `:selected-fg` | green | Highlighted row color |

**Keys**

| Key | Action |
|-----|--------|
| ↑/↓ k/j | Move cursor |
| g/G | First/last row |
| enter | Select row |
| q/ctrl-c | Quit |

---

### `tiki.style text opts`

Non-interactive. Renders styled/boxed text and returns the result string.

```fennel
(print (tiki.style "Hello!" {:border  :rounded
                             :padding 1
                             :fg      tiki.ansi.fg.green
                             :bold    true}))

(print (tiki.style "warning" {:border :normal
                              :margin {:top 1 :bottom 1 :left 2 :right 2}
                              :align  :center
                              :width  30}))
```

| Option | Type | Description |
|--------|------|-------------|
| `:border` | string | `"rounded"` `"normal"` `"double"` `"thick"` `"ascii"` `"none"` |
| `:padding` | number or table | Inner padding — number for all sides, or `{:top :bottom :left :right}` |
| `:margin` | number or table | Outer margin — same format as padding |
| `:width` | number | Minimum inner width (content padded to fill) |
| `:align` | string | `"left"` (default) `"center"` `"right"` |
| `:fg` | ANSI code | Text foreground color |
| `:bg` | ANSI code | Text background color |
| `:bold` | bool | Bold text |
| `:italic` | bool | Italic text |
| `:underline` | bool | Underlined text |

Available border character sets (`tiki.borders`):

```
rounded  ╭─╮  double  ╔═╗  thick  ┏━┓  normal  ┌─┐  ascii  +-+
         │ │          ║ ║         ┃ ┃           │ │          | |
         ╰─╯          ╚═╝         ┗━┛           └─┘          +-+
```

---

## Themes

Apply a built-in theme or supply a custom color table. Themes control the default colors of all interactive widgets.

```fennel
(tiki.set-theme "nord")      ; built-in: default, nord, dracula, gruvbox, light
(tiki.set-theme {})          ; reset to no theme
(tiki.set-theme              ; custom
  {:cursor-fg   (tiki.ansi.fg256 214)
   :prompt-fg   (tiki.ansi.fg256 208)
   :selected-fg (tiki.ansi.fg256 142)
   :match-fg    (tiki.ansi.fg256 229)})
```

Theme keys (all optional):

| Key | Widgets affected |
|-----|-----------------|
| `:cursor-fg` | choose, filter, input, password, write |
| `:prompt-fg` | filter, input, password, write, confirm |
| `:selected-fg` | choose, filter, confirm, table |
| `:selected-attr` | choose, filter, confirm |
| `:unselected-fg` | choose, filter, confirm |
| `:match-fg` | filter |
| `:header-fg` | table |
| `:label-fg` | form |
| `:spinner-fg` | spin |
| `:bar-fg` | progress |

Per-widget options always take precedence over the theme.

```fennel
; Inspect available themes
(each [name _ (pairs tiki.themes)]
  (print name))

; Read or apply the current theme
(tiki.get-theme)
(tiki.apply-theme opts-table)   ; merge current theme into an opts table in-place
```

---

## ANSI utilities

`tiki.ansi` exposes all escape sequences directly.

```fennel
(local ansi tiki.ansi)

;; Attributes
ansi.bold  ansi.dim  ansi.italic  ansi.underline
ansi.blink ansi.reverse ansi.hidden ansi.strikethrough
ansi.reset

;; Standard foreground colors
ansi.fg.black   ansi.fg.red     ansi.fg.green  ansi.fg.yellow
ansi.fg.blue    ansi.fg.magenta ansi.fg.cyan   ansi.fg.white
ansi.fg.default

;; Bright variants
ansi.fg.bright-red   ansi.fg.bright-green  ;; etc.

;; Background colors (same names under ansi.bg.*)
ansi.bg.red  ansi.bg.blue  ;; etc.

;; 256-color and true-color
(ansi.fg256 196)          ; → "\027[38;5;196m"
(ansi.bg256 24)           ; → "\027[48;5;24m"
(ansi.fg-rgb 255 128 0)   ; → "\027[38;2;255;128;0m"
(ansi.bg-rgb 0 0 0)

;; Apply styles to a string
(ansi.style "text" ansi.bold ansi.fg.green)   ; → styled string
(ansi.strip styled-string)                     ; → plain string
(ansi.len  styled-string)                      ; → visual width (UTF-8 aware, strips ANSI)

;; Cursor movement (strings/functions)
ansi.cursor.hide  ansi.cursor.show
ansi.cursor.save  ansi.cursor.restore
(ansi.cursor.up n)     (ansi.cursor.down n)
(ansi.cursor.left n)   (ansi.cursor.right n)
(ansi.cursor.col n)    (ansi.cursor.pos row col)

;; Screen
ansi.screen.clear        ansi.screen.home
ansi.screen.clear-line   ansi.screen.clear-right  ansi.screen.clear-left
ansi.screen.alt-on       ansi.screen.alt-off
```

---

## Clipboard

```fennel
(tiki.clipboard-copy "text to copy")
(local text (tiki.clipboard-paste))   ; returns string or nil
```

Uses `pbcopy`/`pbpaste` on macOS, `xclip` or `xsel` on Linux. No error is raised if none are available.

---

## Fuzzy matching

The filter widget's matching functions are also exported:

```fennel
;; Returns a list of matched byte positions, or nil
(tiki.fuzzy-match "hello world" "hlo")   ; → {1 3 5}

;; Filter a list of strings
;; Returns [{:i orig-index :item string :positions [...]}]
(local filter-m (require :tiki.widget.filter))
(filter-m.filter-items items query fuzzy?)
```

---

## License

[Mozilla Public License 2.0](LICENSE)

---

## Development

```sh
make test     # run test suite (requires fennel + faith vendored in fnl/)
make demo     # run the interactive demo
make compile  # compile all .fnl → lua/
make repl     # start a Fennel REPL with the correct path
```

Tests live in `fnl/tiki/test/`, one file per module. The test runner is `test.fnl` using [faith](https://git.sr.ht/~technomancy/faith) (vendored at `fnl/faith.fnl`).
