(local ansi (require "tiki.ansi"))

(local confirm-m (require "tiki.widget.confirm"))

(local input-m (require "tiki.widget.input"))

(local password-m (require "tiki.widget.password"))

(local write-m (require "tiki.widget.write"))

(local theme (require "tiki.theme"))

(local default-opts {:label-fg ansi.fg.cyan})

(fn form [fields user-opts]
  (let [opts (collect [k v (pairs default-opts)] k v)]
    (theme.apply opts)
    (when user-opts
      (each [k v (pairs user-opts)]
        (tset opts k v)))
    (var result {})
    (var aborted false)
    (each [_ field (ipairs fields)]
      (when (not aborted)
        (let [field-opts (or field.opts {})
              key (or field.key field.label (tostring field.type))
              val (match field.type
                    "input" (do
                              (when field.label
                                (print (ansi.style field.label ansi.bold opts.label-fg)))
                              (input-m.input field-opts))
                    "password" (do
                                 (when field.label
                                   (print (ansi.style field.label ansi.bold opts.label-fg)))
                                 (password-m.password field-opts))
                    "confirm" (confirm-m.confirm (or field.label "Continue?") field-opts)
                    "write" (do
                              (when field.label
                                (print (ansi.style field.label ansi.bold opts.label-fg)))
                              (write-m.write field-opts))
                    _ (error (.. "tiki.form: unknown field type " field.type)))]
          (if (= val nil)
              (set aborted true)
              (tset result key val)))))
    (when (not aborted)
      result)))

{:form form}
