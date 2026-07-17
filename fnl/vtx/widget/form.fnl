(local ansi (require "vtx.ansi"))

(local autocomplete-m (require "vtx.widget.autocomplete"))

(local date-picker-m (require "vtx.widget.date-picker"))

(local checklist-m (require "vtx.widget.checklist"))

(local choose-m (require "vtx.widget.choose"))

(local confirm-m (require "vtx.widget.confirm"))

(local file-picker-m (require "vtx.widget.file-picker"))

(local filter-m (require "vtx.widget.filter"))

(local input-m (require "vtx.widget.input"))

(local num-input-m (require "vtx.widget.num-input"))

(local password-m (require "vtx.widget.password"))

(local radio-m (require "vtx.widget.radio"))

(local slider-m (require "vtx.widget.slider"))

(local term (require "vtx.term"))

(local theme (require "vtx.theme"))

(local write-m (require "vtx.widget.write"))

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
        (var field-done false)
        (while (not field-done)
          (let [field-opts (or field.opts {})
                items (or field.items [])
                key (or field.key field.label (tostring field.type))
                val (match field.type
                      "input" (do
                                (when field.label
                                  (term.writeln (ansi.style field.label ansi.bold opts.label-fg)))
                                (input-m.input field-opts))
                      "password" (do
                                   (when field.label
                                     (term.writeln (ansi.style field.label ansi.bold opts.label-fg)))
                                   (password-m.password field-opts))
                      "confirm" (confirm-m.confirm (or field.label "Continue?") field-opts)
                      "write" (do
                                (when field.label
                                  (term.writeln (ansi.style field.label ansi.bold opts.label-fg)))
                                (write-m.write field-opts))
                      "num-input" (do
                                    (when field.label
                                      (term.writeln (ansi.style field.label ansi.bold opts.label-fg)))
                                    (num-input-m.num-input field-opts))
                      "choose" (do
                                 (when field.label
                                   (term.writeln (ansi.style field.label ansi.bold opts.label-fg)))
                                 (choose-m.choose items field-opts))
                      "radio" (do
                                (when field.label
                                  (term.writeln (ansi.style field.label ansi.bold opts.label-fg)))
                                (radio-m.radio items field-opts))
                      "checklist" (do
                                    (when field.label
                                      (term.writeln (ansi.style field.label ansi.bold opts.label-fg)))
                                    (checklist-m.checklist items field-opts))
                      "filter" (do
                                 (when field.label
                                   (term.writeln (ansi.style field.label ansi.bold opts.label-fg)))
                                 (filter-m.filter items field-opts))
                      "slider" (do
                                 (when field.label
                                   (term.writeln (ansi.style field.label ansi.bold opts.label-fg)))
                                 (slider-m.slider field-opts))
                      "autocomplete" (do
                                       (when field.label
                                         (term.writeln (ansi.style field.label ansi.bold opts.label-fg)))
                                       (autocomplete-m.autocomplete items field-opts))
                      "file" (file-picker-m.file-picker field-opts)
                      "date" (do
                               (when field.label
                                 (term.writeln (ansi.style field.label ansi.bold opts.label-fg)))
                               (date-picker-m.date-picker field-opts))
                      _ (error (.. "vtx.form: unknown field type " (tostring field.type))))]
            (if (= val nil)
                (do
                  (set aborted true)
                  (set field-done true))
                (let [err (and field.validate (field.validate val))]
                  (if err
                      (term.writeln (ansi.style (.. "✗ " err) ansi.fg.red))
                      (do
                        (tset result key val)
                        (set field-done true)))))))))
    (when (not aborted)
      result)))

{:form form}
