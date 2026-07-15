(local posix (require "tiki.posix"))

(local term (require "tiki.term"))

(local ansi (require "tiki.ansi"))

(local theme (require "tiki.theme"))

(local level-colors {:error ansi.fg.red
                     :info ansi.fg.cyan
                     :success ansi.fg.green
                     :warn ansi.fg.yellow})

(local level-icons {:error "✗ " :info "● " :success "✓ " :warn "⚠ "})

(local default-opts {:level "info" :timeout 3})

(fn toast [message user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (let [color (or (. level-colors opts.level) ansi.fg.cyan)
          icon (or (. level-icons opts.level) "")
          line (ansi.style (.. icon message) color)]
      (term.write (.. "\r" line ansi.screen.clear-right))
      (posix.sleep opts.timeout)
      (term.write (.. "\r" ansi.screen.clear-right)))))

{:toast toast}
