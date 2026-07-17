(local ansi (require "vtx.ansi"))

(local checklist-m (require "vtx.widget.checklist"))

(local faith (require "faith"))

(local default-opts {:cursor "> "
                     :cursor-fg ansi.fg.cyan
                     :selected-fg ansi.fg.green
                     :unselected-fg ansi.fg.white})

;;; render-item

(fn test-ri-unchecked-has-empty-box []
  (let [s (checklist-m.render-item "item" 1 2 {} default-opts 80)]
    (faith.is (: (ansi.strip s) "find" "[ ]" 1 true))))

(fn test-ri-checked-has-x-box []
  (let [checked {1 true}
        s (checklist-m.render-item "item" 1 2 checked default-opts 80)]
    (faith.is (: (ansi.strip s) "find" "[x]" 1 true))))

(fn test-ri-cursor-has-prefix []
  (let [s (checklist-m.render-item "item" 1 1 {} default-opts 80)]
    (faith.is (: (ansi.strip s) "find" "> " 1 true))))

(fn test-ri-non-cursor-has-spaces []
  (let [s (ansi.strip (checklist-m.render-item "item" 2 1 {} default-opts 80))]
    (faith.is (: s "find" "^  " 1))))

(fn test-ri-item-text-present []
  (let [s (checklist-m.render-item "hello" 1 2 {} default-opts 80)]
    (faith.is (: (ansi.strip s) "find" "hello" 1 true))))

(fn test-ri-cursor-item-has-escape []
  (let [s (checklist-m.render-item "item" 1 1 {} default-opts 80)]
    (faith.is (: s "find" "\027"))))

(fn test-ri-checked-cursor []
  (let [checked {1 true}
        s (checklist-m.render-item "item" 1 1 checked default-opts 80)]
    (faith.is (: (ansi.strip s) "find" "[x]" 1 true))
    (faith.is (: (ansi.strip s) "find" "> " 1 true))))

(fn test-ri-content-order []
  ; stripped result should be: prefix + box + space + text
  (let [s (ansi.strip (checklist-m.render-item "hello" 1 1 {} default-opts 80))]
    (faith.is (: s "find" "> %[%s%] hello"))))

(fn test-ri-checked-content-order []
  (let [s (ansi.strip (checklist-m.render-item "hello" 1 1 {1 true} default-opts 80))]
    (faith.is (: s "find" "> %[x%] hello"))))

{:test-ri-checked-content-order test-ri-checked-content-order
 :test-ri-checked-cursor test-ri-checked-cursor
 :test-ri-checked-has-x-box test-ri-checked-has-x-box
 :test-ri-content-order test-ri-content-order
 :test-ri-cursor-has-prefix test-ri-cursor-has-prefix
 :test-ri-cursor-item-has-escape test-ri-cursor-item-has-escape
 :test-ri-item-text-present test-ri-item-text-present
 :test-ri-non-cursor-has-spaces test-ri-non-cursor-has-spaces
 :test-ri-unchecked-has-empty-box test-ri-unchecked-has-empty-box}
