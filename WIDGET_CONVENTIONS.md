# Widget conventions

Conventions all widgets in `fnl/vtx/widget/` should follow. Grep the codebase and
you'll find drift — this doc is the target state, not the current state.

## Signature

- Widgets accept `(items? user-opts?)`. Items list first, options table second.
- `user-opts` is always optional. Defaults come from a per-widget `default-opts`
  local, merged via `theme.merge default-opts user-opts`.
- `theme.apply` is called by `theme.merge` — do not call it directly.

## Return values

- **Cancel** (Ctrl-C, q, ESC in most widgets): return `nil`.
- **Single select** (choose, radio, filter without `:multi`, tree, file-picker,
  autocomplete, input, password, num-input, slider, date-picker): return the
  selected value.
- **Multi-select** (checklist, choose+multi, filter+multi, table+multi): return
  an array of selected items. Empty array if nothing selected but confirmed.
- **Confirmation** (confirm): return `true`/`false`. Cancel returns `nil`.
- **Form/multi-form**: return an assoc table `{key value ...}`. `nil` on cancel.
- **Toast, spin, progress**: return the wrapped fn's return value.
- **Void widgets** (write, pager, viewport): return string content or `nil`.

## Key bindings

Common. Widgets pick from this set. Don't invent new keys for the same action.

| Action           | Keys                                     |
|------------------|------------------------------------------|
| Cursor up        | `up`, `k`, `\016` (Ctrl-P)               |
| Cursor down      | `down`, `j`, `\014` (Ctrl-N)             |
| Cursor left      | `left`, `h`, `\002` (Ctrl-B)             |
| Cursor right     | `right`, `l`, `\006` (Ctrl-F)            |
| Home             | `home`, `\001` (Ctrl-A)                  |
| End              | `end`, `\005` (Ctrl-E)                   |
| Delete-backward  | `\b`, `\127` (backspace, DEL)            |
| Delete-forward   | `delete`, `\004` (Ctrl-D)                |
| Page up          | `page-up`, `\002` (Ctrl-B) *             |
| Page down        | `page-down`, `\006` (Ctrl-F) *           |
| Go to top        | `g`                                      |
| Go to bottom     | `G`                                      |
| Confirm/select   | `\r`, `\n` (Enter)                       |
| Cancel/quit      | `q`, `\003` (Ctrl-C), `escape`           |
| Toggle mark      | `space`                                  |
| Select all       | `a`                                      |
| Search           | `/`                                      |
| Next search      | `n`                                      |
| Prev search      | `N`                                      |
| Undo             | `\026` (Ctrl-Z)                          |
| Kill word back   | `\023` (Ctrl-W), `\027\127` (Meta-DEL)   |
| Kill line end    | `\v` (Ctrl-K)                            |
| Kill whole       | `\021` (Ctrl-U)                          |
| Paste            | `\025` (Ctrl-Y)                          |
| Bracketed paste  | `{:paste content}` table from read-key   |

\* Ctrl-B/Ctrl-F conflict between "cursor left/right" and "page up/down". Text
input widgets bind them to cursor motion; list widgets bind them to paging.
Widgets that offer both should prefer arrow keys for cursor motion and reserve
Ctrl-B/F for paging.

`q` is only bound where the widget's input doesn't accept `q` as data. Input,
password, write, filter, autocomplete, num-input never bind `q` because it's
valid content.

## Options

Common opts. Not all widgets use all of them.

| Opt              | Type         | Meaning                                  |
|------------------|--------------|------------------------------------------|
| `:height`        | int / nil    | Rows shown. `nil` = auto or terminal.    |
| `:prompt`        | string / nil | Prompt shown above/beside input.         |
| `:prompt-fg`     | ansi         | Prompt color.                            |
| `:cursor`        | string       | Cursor marker glyph ("> " etc.).         |
| `:cursor-fg`     | ansi         | Cursor color.                            |
| `:selected-fg`   | ansi         | Selected item color.                     |
| `:unselected-fg` | ansi         | Unselected item color.                   |
| `:selected-attr` | ansi         | Extra attr for selected (usually bold).  |
| `:multi`         | bool         | Allow multiple selection.                |
| `:value`         | any          | Initial value.                           |
| `:alt-screen`    | bool         | Use alt screen buffer (choose, filter, pager). |

## Rendering

- Every frame, widgets call `list-nav.clamp`, then render, then `read-key`.
- Frame content should be built once per frame and (optionally) passed through
  `term.render-frame` to skip identical redraws.
- Cleanup happens outside `with-raw` via `term.clear-rows N` to erase the widget
  before returning.

## Alt-screen

Widgets that support `:alt-screen`: choose, filter, pager. These take over the
whole terminal and restore on exit. They skip the `term.clear-rows` cleanup
because alt-off restores the previous state.

## Signals

`with-raw` installs SIGWINCH detection (surfaces as key `"resize"`). Fatal
signals (SIGINT/TERM/HUP/QUIT) are handled by the native module — terminal is
restored to cooked mode before the default action fires.

## Bracketed paste

`with-raw` accepts `?opts.bracketed-paste`. When enabled, `read-key` returns
`{:paste "..."}` for paste chunks. Widgets that consume paste (`input`, `write`)
should match against tables:

```fennel
(match k
  {:paste content} (insert-at-cursor content)
  ...)
```

## Mouse

`with-raw` accepts `?opts.mouse`. When enabled, `read-key` returns
`{:mouse true :button B :col C :row R}` for click events.
