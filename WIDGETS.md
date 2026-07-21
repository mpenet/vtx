# Widget reference

Compact reference for every widget in `vtx`. See `WIDGET_CONVENTIONS.md` for
cross-cutting rules (return values, common opts, keybindings).

## Text input

### `input opts` → string | nil
Single-line text input.
- Opts: `:prompt`, `:prompt-fg`, `:cursor-fg`, `:value`, `:placeholder`,
  `:history` (list), `:on-change` (fn), `:complete` (fn returning candidates).
- Keys: standard editing + `\t` (tab-complete ghost), `\016`/`\014` (history
  prev/next), `\026` (undo), `\025` (paste), `\027d`/`\027f`/`\027b`
  (word ops), `\023` (kill word back).

### `password opts` → string | nil
Masked input.
- Opts: `:prompt`, `:cursor-fg`, `:mask` ("•"), `:confirm` (bool),
  `:confirm-prompt`.
- Keys: standard editing + `\018` (Ctrl-R toggle reveal).

### `num-input opts` → number | nil
Numeric input with validation.
- Opts: `:prompt`, `:min`, `:max`, `:step`, `:decimals`, `:value`.
- Keys: `up`/`down` (step), `page-up`/`page-down` (10× step),
  `home`/`end` (min/max), digits, `-`, `.`.

### `write opts` → string | nil
Multi-line text editor.
- Opts: `:prompt`, `:header`, `:height` (viewport rows), `:width`,
  `:value`, `:on-change`, `:cursor-fg`.
- Keys: standard editing + `\r` (newline), `\017` (Ctrl-Q quit),
  Ctrl-C Ctrl-C to submit, `\026` (undo, 20-level stack), `\025` (paste),
  `\027d`/`\027f`/`\027b` (word ops).

## Selection

### `choose items opts` → item | [items] | nil
Single or multi-select from a list.
- Opts: `:height`, `:cursor`, `:multi`, `:search`, `:alt-screen`,
  `:cursor-fg`, `:selected-fg`, `:selected-attr`, `:unselected-fg`.
- Keys: standard nav + `space` (toggle in multi), `/` (search when enabled),
  `n`/`N` (cycle matches).

### `filter items opts` → item | [items] | nil
Filter-as-you-type. Fuzzy by default.
- Opts: `:prompt`, `:height`, `:cursor`, `:multi`, `:fuzzy` (bool, default
  true), `:recent` (list, shown first when query empty), `:render` (fn),
  `:match-fg`, `:alt-screen`.
- Keys: standard nav + typing filters, `\t` (toggle mark in multi).

### `checklist items opts` → [items]
Multi-select with cursor + toggles. Always returns array (empty if none).
- Opts: `:height`, `:cursor`, `:checked` (initial idx list),
  `:cursor-fg`, `:selected-fg`, `:unselected-fg`.
- Keys: standard nav + `space` (toggle), `a` (select all / clear).

### `radio items opts` → item | nil
Single-choice with visual bullet.
- Opts: `:height`, `:prompt`, `:value` (initial), `:cursor-fg`,
  `:selected-fg`, `:unselected-fg`.
- Keys: standard nav + `space` (select).

### `autocomplete items opts` → string | nil
Text input with suggestions from `items`.
- Opts: `:prompt`, `:height`, `:cursor-fg`, `:fuzzy`.
- Keys: `up`/`down`/Ctrl-P/Ctrl-N (cycle), `\t` (accept), typing filters.

### `confirm prompt opts` → bool | nil
Yes/no with left/right toggle.
- Opts: `:default` (true|false), `:affirmative` ("Yes"), `:negative` ("No"),
  `:prompt-fg`, `:selected-attr`, `:selected-fg`, `:unselected-fg`.
- Keys: `left`/`right`/`h`/`l` (toggle), `y`/`n` (direct), Enter.

## Compound

### `form fields opts` → assoc | nil
Sequential field prompts. Fields:
`{:type "input"|... :label :key :opts :items :validate (fn value → err|nil)}`.
- Opts: `:label-fg`.
- Cancel in any field aborts the whole form.

### `multi-form fields opts` → assoc | nil
All fields visible on screen, Tab between them.
- Fields: `{:type "input"|"password"|"num"|"confirm" :label :key :opts}`.
- Opts: `:active-fg`, `:label-fg`, `:value-fg`, `:cursor-char`.
- Keys: `\t` (next field), Enter on last field submits.

### `dialog message buttons opts` → button-index | nil
Boxed message with clickable button row.
- Opts: `:border`, `:padding`, `:width`, `:fg`, `:active-fg`, `:button-sep`.
- Keys: `left`/`right`/`h`/`l`/`\t` (cycle), Enter (confirm).

## Layout / display

### `tabs tab-list opts` → active-index | nil
Row of tabs with content below.
- `tab-list`: `[{:label :content} ...]`.
- Opts: `:active-fg`, `:inactive-fg`.
- Keys: `left`/`right`/`h`/`l`/`\t` (cycle), digits 1-9 (jump), Enter.

### `tree nodes opts` → node-data | nil
Hierarchical selection.
- `nodes`: `[{:label :children [nodes] :data any} ...]`.
- Opts: `:collapsed-char` ("▶"), `:expanded-char` ("▼"), `:leaf-char` ("•"),
  `:indent`, `:cursor-fg`, `:dir-fg`.
- Keys: `up`/`down`/Ctrl-P/Ctrl-N + `right`/`l` (expand),
  `left`/`h` (collapse), `space` (toggle), Enter (select leaf or toggle).

### `tbl headers rows opts` → row | [rows] | nil
Sortable, selectable table.
- Opts: `:height`, `:multi`, `:select`, `:sort-col`, `:sort-asc`, `:sep`.
- Keys: standard nav + `<`/`>` (cycle sort col), `s` (toggle asc/desc),
  `0` (clear sort), `space` (mark in multi), Enter (confirm).

### `pager text opts` → nil
Less-style text viewer.
- Opts: `:height`, `:wrap`, `:alt-screen`, `:highlight` (fn line → styled).
- Keys: nav + `space`/`page-down`/`page-up` (paging),
  `/` (search), `n`/`N` (next/prev match), `l` (toggle line #s),
  `w` (toggle wrap), digits + `G` (jump to line).

### `viewport content opts` → nil
Simple scrolling viewer, no wrap/search.
- Opts: `:height`.
- Keys: nav.

### `file-picker opts` → path | nil
Filesystem browser.
- Opts: `:path`, `:height`, `:show-hidden`, `:dirs-only`,
  `:cursor-fg`, `:dir-fg`.
- Keys: `up`/`down`/Ctrl-P/Ctrl-N + `right`/Enter (enter dir/pick file),
  `left`/`\b`/`\127` (go up).

### `date-picker opts` → "YYYY-MM-DD" | nil
Year/month/day segment picker.
- Opts: `:prompt`, `:separator`, `:value`, `:active-fg`, `:fg`.
- Keys: `left`/`right`/`\t` (segment), `up`/`down` (adjust), Enter.

### `slider opts` → number | nil
Horizontal bar slider.
- Opts: `:min`, `:max`, `:step`, `:value`, `:width`,
  `:thumb-char`, `:filled-char`, `:empty-char`, `:prompt`, `:format-fn`.
- Keys: `left`/`right`/`h`/`l` (step), `g`/`G` (min/max), Enter.

## Progress / status

### `spin f opts` → f's result
Show spinner while `f` runs. Cooperative: `f` receives no args and can
`coroutine.yield` a string to update title.
- Opts: `:spinner` ("dots" default), `:interval` (ms), `:title`, `:spinner-fg`.

### `multi-spin tasks opts` → [results]
Concurrent spinners. `tasks = [{:f :title} ...]`.
- Each `f` runs as a coroutine, yields to advance frame.

### `progress f opts` → nil
Progress bar. `f` receives an `update(value, ?total)` callback.
- Opts: `:width`, `:bar-fg`, `:indeterminate`, `:show-rate`, `:show-eta`,
  `:unit` ("B" for byte-formatted rate), `:interval`.

### `multi-progress tasks opts` → nil
Concurrent progress bars. `tasks = [{:f :title} ...]`.

### `gauge value ?total opts` → string
Non-interactive filled bar. Returns the styled string.
- Opts: `:width`, `:fill`, `:empty`, `:bar-fg`, `:label`, `:show-pct`.

### `sparkline data opts` → string
Non-interactive mini bar chart.
- Opts: `:label`, `:fg`.

### `toast message opts` → nil
Timed notification.
- Opts: `:level` ("info"|"success"|"warn"|"error"), `:timeout` (seconds).

### `key-help bindings opts` → string
Non-interactive keybinding row.
- `bindings`: `[{:key :desc} ...]`.
- Opts: `:sep`, `:key-fg`, `:desc-fg`.

## Style / layout functions

### `style text opts` → string
Wrap text with border/padding/margin/color.
- Opts: `:border`, `:padding`, `:margin`, `:width`, `:align`, `:wrap`,
  `:fg`, `:bg`, `:bold`, `:italic`, `:underline`.

### `place content opts` → string
Position text within a bounding box.
- Opts: `:width`, `:height`, `:halign` ("left"|"center"|"right"),
  `:valign` ("top"|"middle"|"bottom").

### `separator opts` → string
Horizontal rule with optional label.
- Opts: `:width`, `:label`, `:border`, `:fg`, `:margin-left`.

### `hbox items opts` → string
Horizontally arrange multi-line strings.
- Opts: `:gap`, `:valign` ("top"|"center"|"bottom").

### `vbox items opts` → string
Vertically stack with gap.
- Opts: `:gap`.

### `grid items opts` → string
Grid of cells auto-sized per column.
- Opts: `:cols`, `:gap-h`, `:gap-v`.

## Gradients

`gradient-text text stops` — per-char color gradient.
`gradient-lines text stops` — per-line color gradient.
`gradient-bg-lines text stops` — per-line background gradient.
Stops = list of hex strings (`"#ff0000"` or `"#f00"`).

## Themes

`set-theme name-or-table` — activate a theme.
`get-theme` — current theme table.
`themes` — table of built-in themes (`default`, `dracula`, `gruvbox`, `light`,
`nord`, `tron`).
`apply-theme opts` — apply current theme to an opts table (only overrides keys
already present).

## Namespaced access

For discoverability, `vtx` also exports grouped tables:
- `vtx.widgets` — all interactive widgets
- `vtx.styles` — layout/style helpers
- `vtx.gradients` — gradient functions
- `vtx.themes-api` — theme functions
- `vtx.util` — misc utilities
