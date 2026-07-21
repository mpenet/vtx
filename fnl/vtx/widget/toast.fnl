(local posix (require "vtx.posix"))

(local term (require "vtx.term"))

(local ansi (require "vtx.ansi"))

(local theme (require "vtx.theme"))

(local level-colors {:error ansi.fg.red
                     :info ansi.fg.cyan
                     :success ansi.fg.green
                     :warn ansi.fg.yellow})

(local level-icons {:error "✗ " :info "● " :success "✓ " :warn "⚠ "})

(local default-opts {:level "info" :timeout 3})

(fn toast [message user-opts]
  (let [opts (theme.merge default-opts user-opts)]
    (let [color (or (. level-colors opts.level) ansi.fg.cyan)
          icon (or (. level-icons opts.level) "")
          line (ansi.style (.. icon message) color)]
      (term.write (.. "\r" line ansi.screen.clear-right))
      (posix.sleep opts.timeout)
      (term.write (.. "\r" ansi.screen.clear-right)))))

{:level-colors level-colors :level-icons level-icons :toast toast}
