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
  (let [opts (theme.merge default-opts user-opts)]
    (fn write-label [label]
      (when label
        (term.writeln (ansi.style label ansi.bold opts.label-fg))))
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
                                (write-label field.label)
                                (input-m.input field-opts))
                      "password" (do
                                   (write-label field.label)
                                   (password-m.password field-opts))
                      "confirm" (confirm-m.confirm (or field.label "Continue?") field-opts)
                      "write" (do
                                (write-label field.label)
                                (write-m.write field-opts))
                      "num-input" (do
                                    (write-label field.label)
                                    (num-input-m.num-input field-opts))
                      "choose" (do
                                 (write-label field.label)
                                 (choose-m.choose items field-opts))
                      "radio" (do
                                (write-label field.label)
                                (radio-m.radio items field-opts))
                      "checklist" (do
                                    (write-label field.label)
                                    (checklist-m.checklist items field-opts))
                      "filter" (do
                                 (write-label field.label)
                                 (filter-m.filter items field-opts))
                      "slider" (do
                                 (write-label field.label)
                                 (slider-m.slider field-opts))
                      "autocomplete" (do
                                       (write-label field.label)
                                       (autocomplete-m.autocomplete items field-opts))
                      "file" (file-picker-m.file-picker field-opts)
                      "date" (do
                               (write-label field.label)
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
