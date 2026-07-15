(local ansi (require "tiki.ansi"))

(local kh-m (require "tiki.widget.key-help"))

(local faith (require "faith"))

(fn test-key-help-contains-key []
  (let [s (kh-m.key-help [{:desc "navigate" :key "↑↓"}] {})]
    (faith.is (: (ansi.strip s) "find" "↑↓" 1 true))))

(fn test-key-help-contains-desc []
  (let [s (kh-m.key-help [{:desc "navigate" :key "↑↓"}] {})]
    (faith.is (: (ansi.strip s) "find" "navigate" 1 true))))

(fn test-key-help-multi-keys []
  (let [s (kh-m.key-help [{:desc "move" :key "↑↓"} {:desc "select" :key "space"}] {})]
    (faith.is (: (ansi.strip s) "find" "move" 1 true))
    (faith.is (: (ansi.strip s) "find" "select" 1 true))))

(fn test-key-help-custom-sep []
  (let [s (kh-m.key-help [{:desc "a" :key "x"} {:desc "b" :key "y"}] {:sep " | "})]
    (faith.is (: (ansi.strip s) "find" " | " 1 true))))

(fn test-key-help-has-ansi []
  (let [s (kh-m.key-help [{:desc "move" :key "↑↓"}] {})]
    (faith.is (: s "find" "\027" 1 true))))

(fn test-key-help-empty []
  (let [s (kh-m.key-help [] {})]
    (faith.= "" s)))

(fn test-key-help-default-sep []
  (let [s (kh-m.key-help [{:desc "a" :key "x"} {:desc "b" :key "y"}] {})]
    (faith.is (: (ansi.strip s) "find" "  " 1 true))))

(fn test-key-help-space-between-key-and-desc []
  (let [s (kh-m.key-help [{:desc "quit" :key "q"}] {})]
    (faith.is (: (ansi.strip s) "find" "q quit" 1 true))))

{:test-key-help-contains-desc test-key-help-contains-desc
 :test-key-help-contains-key test-key-help-contains-key
 :test-key-help-custom-sep test-key-help-custom-sep
 :test-key-help-default-sep test-key-help-default-sep
 :test-key-help-empty test-key-help-empty
 :test-key-help-has-ansi test-key-help-has-ansi
 :test-key-help-multi-keys test-key-help-multi-keys
 :test-key-help-space-between-key-and-desc test-key-help-space-between-key-and-desc}
