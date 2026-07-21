(local keymap (require "vtx.keymap"))

(local faith (require "faith"))

(fn test-lookup-hit []
  (faith.= :up (keymap.lookup {:up ["up" "k"]} "k")))

(fn test-lookup-miss []
  (faith.= nil (keymap.lookup {:up ["up"]} "x")))

(fn test-lookup-empty []
  (faith.= nil (keymap.lookup {} "any")))

(fn test-lookup-multiple-actions []
  (let [km {:up ["up" "k"] :down ["down" "j"]}]
    (faith.= :up (keymap.lookup km "up"))
    (faith.= :down (keymap.lookup km "down"))
    (faith.= :down (keymap.lookup km "j"))))

(fn test-merge-defaults-only []
  (let [m (keymap.merge {:up ["up"]} nil)]
    (faith.= [:up] (. m :up))))

(fn test-merge-user-adds-new-action []
  (let [m (keymap.merge {:up ["up"]} {:cancel ["escape"]})]
    (faith.= [:up] m.up)
    (faith.= [:escape] m.cancel)))

(fn test-merge-user-overrides-action []
  ;; user override completely REPLACES keys for that action
  (let [m (keymap.merge {:up ["up" "k"]} {:up ["w"]})]
    (faith.= [:w] m.up)
    (faith.= :up (keymap.lookup m "w"))
    (faith.= nil (keymap.lookup m "k"))))

(fn test-merge-nil-defaults []
  (let [m (keymap.merge nil {:up ["up"]})]
    (faith.= [:up] m.up)))

(fn test-merge-both-nil []
  (let [m (keymap.merge nil nil)]
    (faith.= nil m.up)))

(fn test-nav-defaults-has-up-down []
  (faith.= :up (keymap.lookup keymap.nav-defaults "up"))
  (faith.= :up (keymap.lookup keymap.nav-defaults "k"))
  (faith.= :up (keymap.lookup keymap.nav-defaults "\016"))
  (faith.= :down (keymap.lookup keymap.nav-defaults "down"))
  (faith.= :down (keymap.lookup keymap.nav-defaults "j"))
  (faith.= :down (keymap.lookup keymap.nav-defaults "\014")))

(fn test-nav-defaults-has-confirm-cancel []
  (faith.= :confirm (keymap.lookup keymap.nav-defaults "\r"))
  (faith.= :confirm (keymap.lookup keymap.nav-defaults "\n"))
  (faith.= :cancel (keymap.lookup keymap.nav-defaults "q"))
  (faith.= :cancel (keymap.lookup keymap.nav-defaults "\003"))
  (faith.= :cancel (keymap.lookup keymap.nav-defaults "escape")))

(fn test-nav-defaults-has-paging []
  (faith.= :page-up (keymap.lookup keymap.nav-defaults "page-up"))
  (faith.= :page-down (keymap.lookup keymap.nav-defaults "page-down"))
  (faith.= :top (keymap.lookup keymap.nav-defaults "g"))
  (faith.= :bottom (keymap.lookup keymap.nav-defaults "G")))

(fn test-text-defaults-editing []
  (faith.= :backspace (keymap.lookup keymap.text-defaults "\b"))
  (faith.= :backspace (keymap.lookup keymap.text-defaults "\127"))
  (faith.= :delete-forward (keymap.lookup keymap.text-defaults "delete"))
  (faith.= :delete-forward (keymap.lookup keymap.text-defaults "\004"))
  (faith.= :undo (keymap.lookup keymap.text-defaults "\026"))
  (faith.= :paste (keymap.lookup keymap.text-defaults "\025")))

(fn test-text-defaults-motion []
  (faith.= :left (keymap.lookup keymap.text-defaults "left"))
  (faith.= :left (keymap.lookup keymap.text-defaults "\002"))
  (faith.= :right (keymap.lookup keymap.text-defaults "right"))
  (faith.= :home (keymap.lookup keymap.text-defaults "\001"))
  (faith.= :end (keymap.lookup keymap.text-defaults "\005")))

{:test-lookup-empty test-lookup-empty
 :test-lookup-hit test-lookup-hit
 :test-lookup-miss test-lookup-miss
 :test-lookup-multiple-actions test-lookup-multiple-actions
 :test-merge-both-nil test-merge-both-nil
 :test-merge-defaults-only test-merge-defaults-only
 :test-merge-nil-defaults test-merge-nil-defaults
 :test-merge-user-adds-new-action test-merge-user-adds-new-action
 :test-merge-user-overrides-action test-merge-user-overrides-action
 :test-nav-defaults-has-confirm-cancel test-nav-defaults-has-confirm-cancel
 :test-nav-defaults-has-paging test-nav-defaults-has-paging
 :test-nav-defaults-has-up-down test-nav-defaults-has-up-down
 :test-text-defaults-editing test-text-defaults-editing
 :test-text-defaults-motion test-text-defaults-motion}
