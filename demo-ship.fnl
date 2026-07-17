(local fennel (require "fennel"))

(set fennel.path (.. "fnl/?.fnl;fnl/?/init.fnl;" fennel.path))

(local vtx (require "vtx"))

(local ansi vtx.ansi)

(local util (require "vtx.util"))

(vtx.set-theme "tron")

(math.randomseed (os.time))

(fn pause [secs]
  (let [t (os.clock)]
    (while (< (os.clock) (+ t secs)))))

(fn section [label]
  (print "")
  (print (vtx.separator {:border "normal"
                         :fg (ansi.fg256 238)
                         :label (ansi.style (.. " " label " ") ansi.bold (ansi.fg256 48))
                         :width 62})))

(print "")

(print (vtx.gradient-text "  V · T · X  —  N A V I G A T I O N  S Y S T E M  " ["#00FF87" "#00FFFF" "#00FF00"]))

(print (ansi.style (.. "  DEEP SPACE VESSEL  ·  STARDATE " (os.date "%Y.%j.%H%M") "  ") (ansi.fg256 240)))

(print "")

(vtx.multi-spin [{:f
                  (fn []
                    (pause 0.5)
                    "ONLINE")
                  :title
                  "NAVCOM CORE          "}
                 {:f
                  (fn []
                    (pause 0.3)
                    "ONLINE")
                  :title
                  "STAR CHART DATABASE  "}
                 {:f
                  (fn []
                    (pause 0.7)
                    "ONLINE")
                  :title
                  "SENSOR ARRAY         "}
                 {:f
                  (fn []
                    (pause 0.4)
                    "ONLINE")
                  :title
                  "SHIELD MATRIX        "}
                 {:f
                  (fn []
                    (pause 0.8)
                    "ONLINE")
                  :title
                  "HYPERDRIVE COILS     "}
                 {:f
                  (fn []
                    (pause 0.2)
                    "ONLINE")
                  :title
                  "LIFE SUPPORT         "}] {:spinner "dots" :spinner-fg (ansi.fg256 46)})

(section "SHIP STATUS  [live]")

(let [sensor-buf [42 67 55 89 34 71 90 45 88 72 56 93]
      comms-buf [80 75 82 79 85 88 72 90 87 83 91 88]
      warp-buf [50 55 62 68 74 79 83 87 89 91 92 93]]
  (var hull 0.91)
  (var shields 0.63)
  (var power 0.88)
  (var fuel 0.74)
  (var drawn 0)
  (fn jitter [v d lo hi]
    (math.max lo (math.min hi (+ v (* (- (math.random) 0.45) d)))))
  (fn roll! [buf v]
    (table.remove buf 1)
    (table.insert buf (math.max 0 (math.min 100 (math.floor v)))))
  (fn render-frame []
    (let [sc (if (< shields 0.4)
                 (ansi.fg256 196)
                 (< shields 0.6)
                 (ansi.fg256 226)
                 (ansi.fg256 46))
          gauges (vtx.hbox [(vtx.style (.. (ansi.style "HULL    " (ansi.fg256 48)) "\n" (vtx.gauge hull nil {:bar-fg (ansi.fg256 46) :width 12})) {:border "normal" :padding 1})
                            (vtx.style (.. (ansi.style "SHIELDS " (ansi.fg256 48)) "\n" (vtx.gauge shields nil {:bar-fg sc :width 12})) {:border "normal" :padding 1})
                            (vtx.style (.. (ansi.style "POWER   " (ansi.fg256 48)) "\n" (vtx.gauge power nil {:bar-fg (ansi.fg256 46) :width 12})) {:border "normal" :padding 1})
                            (vtx.style (.. (ansi.style "FUEL    " (ansi.fg256 48)) "\n" (vtx.gauge fuel nil {:bar-fg (ansi.fg256 47) :width 12})) {:border "normal" :padding 1})] {:gap 1})
          sparks (vtx.style (.. (ansi.style "SENSORS   " (ansi.fg256 48)) (vtx.sparkline sensor-buf {:fg (ansi.fg256 46)}) "\n" (ansi.style "COMMS     " (ansi.fg256 48)) (vtx.sparkline comms-buf {:fg (ansi.fg256 48)}) "\n" (ansi.style "WARP FIELD" (ansi.fg256 48)) " " (vtx.sparkline warp-buf {:fg (ansi.fg256 226)})) {:border "normal" :padding 1})
          lines (util.split-lines (.. gauges "\n" sparks))]
      (when (> drawn 0)
        (io.write (.. "\027[" drawn "A")))
      (each [_ line (ipairs lines)]
        (io.write (.. "\r" line "\027[K
                                      ")))
      (io.flush)
      (set drawn (# lines))))
  (for [_ 1 60]
    (set hull (jitter hull 0.04 0.7 1.0))
    (set shields (jitter shields 0.09 0.25 0.95))
    (set power (jitter power 0.03 0.75 1.0))
    (set fuel (math.max 0.3 (- fuel 0.0015)))
    (roll! sensor-buf (jitter (. sensor-buf (# sensor-buf)) 40 10 100))
    (roll! comms-buf (jitter (. comms-buf (# comms-buf)) 15 55 100))
    (roll! warp-buf (jitter (. warp-buf (# warp-buf)) 6 80 100))
    (render-frame)
    (pause 0.07)))

(section "ALERT CONDITION")

(let [levels ["CONDITION GREEN  · all clear, standard operations"
              "CONDITION YELLOW · heightened readiness, shields on standby"
              "CONDITION RED    · battle stations, all hands on deck"
              "CONDITION BLACK  · silent running, non-essential systems off"]
      colors [(ansi.fg256 46) (ansi.fg256 226) (ansi.fg256 196) (ansi.fg256 238)]
      level (vtx.radio levels {})]
  (when level
    (var col (ansi.fg256 46))
    (each [i l (ipairs levels)]
      (when (= l level)
        (set col (. colors i))))
    (print (vtx.style (.. "  " level "  ") {:bold true :border "normal" :fg col}))))

(section "SELECT DESTINATION")

(let [dest (vtx.filter ["SECTOR 7-G          ·  Primary objective  [14.6h]"
                        "RELAY STATION ALPHA  ·  Resupply           [6.2h]"
                        "DEEP SPACE OUTPOST   ·  Emergency shelter  [21.0h]"
                        "ASTEROID BELT R-44   ·  Mining ops         [8.8h]  ⚠"
                        "NEUTRAL ZONE BRAVO   ·  Diplomatic contact [18.3h]"] {:height 5 :prompt (ansi.style "DEST> " (ansi.fg256 46))})]
  (when dest
    (print (vtx.style (.. "  DESTINATION LOCKED: " (. dest 1) "  ") {:bold true :border "normal" :fg (ansi.fg256 46)}))))

(section "AWAY TEAM SELECTION")

(let [selected (vtx.checklist ["Chen, Y.     — Commander"
                               "Okafor, B.   — Lt. Engineer"
                               "Vasquez, M.  — Pilot"
                               "Nakamura, T. — Science Officer"
                               "Reeves, D.   — Medic"] {:height 7})]
  (if (and selected (> (# selected) 0))
      (print (vtx.style (.. "  AWAY TEAM: " (table.concat selected " · ") "  ") {:border "normal" :fg (ansi.fg256 46)}))
      (print (ansi.style "  NO AWAY TEAM ASSIGNED" (ansi.fg256 238)))))

(section "WARP FACTOR")

(let [wf (vtx.slider {:max 9
                      :min 1
                      :prompt (ansi.style "WARP > " (ansi.fg256 46))
                      :step 1
                      :value 5
                      :width 36})]
  (when wf
    (print (vtx.style (.. "  WARP FACTOR " wf " ENGAGED  ") {:bold true :border "normal" :fg (ansi.fg256 46)}))))

(section "HAIL FREQUENCY")

(let [contacts ["STARBASE OMEGA      — Command HQ         [priority]"
                "RELAY STATION ALPHA — Nav beacon         [sector 4]"
                "DEEP SPACE OUTPOST  — Emergency shelter  [sector 9]"
                "USS MERIDIAN        — Sister vessel      [sector 6]"
                "NEUTRAL ZONE BRAVO  — Diplomatic post    [border]"
                "ASTEROID BELT R-44  — Mining ops         [sector 3]"
                "SCIENCE VESSEL HERA — Research partner   [sector 7]"
                "SALVAGE TUG DELTA   — Recovery asset     [sector 5]"]
      contact (vtx.autocomplete contacts {:height 5 :prompt (ansi.style "CONTACT> " (ansi.fg256 46))})]
  (if contact
      (print (vtx.style (.. "  HAILING: " contact "  ") {:bold true :border "normal" :fg (ansi.fg256 46)}))
      (print (ansi.style "  NO CONTACT SELECTED" (ansi.fg256 238)))))

(section "CREW MANIFEST  [enter/q to close]")

(vtx.tbl ["NAME" "RANK" "STATION" "STATUS"] [["Chen, Y." "Commander" "BRIDGE" "READY"]
                                             ["Okafor, B." "Lt. Engineer" "ENGINE RM" "READY"]
                                             ["Vasquez, M." "Pilot" "HELM" "READY"]
                                             ["Nakamura, T." "Science Off." "LAB" "READY"]
                                             ["Reeves, D." "Medic" "MEDBAY" "ON CALL"]] {:height 7})

(section "POWER DISTRIBUTION")

(let [power (vtx.form [{:key "shields"
                        :label (ansi.style "SHIELD POWER  (0–100%)" (ansi.fg256 48))
                        :opts {:max 100 :min 0 :prompt (ansi.style "  > " (ansi.fg256 46)) :value 75}
                        :type "num-input"}
                       {:key "weapons"
                        :label (ansi.style "WEAPONS POWER (0–100%)" (ansi.fg256 48))
                        :opts {:max 100 :min 0 :prompt (ansi.style "  > " (ansi.fg256 46)) :value 50}
                        :type "num-input"}
                       {:key "engines"
                        :label (ansi.style "ENGINE POWER  (0–100%)" (ansi.fg256 48))
                        :opts {:max 100 :min 0 :prompt (ansi.style "  > " (ansi.fg256 46)) :value 90}
                        :type "num-input"}])]
  (when power
    (print (vtx.style (.. "  SHIELDS " power.shields "%  ·  WEAPONS " power.weapons "%  ·  ENGINES " power.engines "%  ") {:border "normal" :fg (ansi.fg256 46)}))))

(section "PRE-LAUNCH SYSTEM CHECKS")

(vtx.multi-progress [{:f
                      (fn [u]
                        (for [i 1 100]
                          (u i 100)))
                      :title
                      "NAVIGATION LOCK      "}
                     {:f
                      (fn [u]
                        (for [i 1 100]
                          (coroutine.yield)
                          (u i 100)))
                      :title
                      "HULL SEAL INTEGRITY  "}
                     {:f
                      (fn [u]
                        (for [i 1 100]
                          (for [_ 1 2]
                            (coroutine.yield))
                          (u i 100)))
                      :title
                      "LIFE SUPPORT SYSTEMS "}
                     {:f
                      (fn [u]
                        (for [i 1 100]
                          (for [_ 1 3]
                            (coroutine.yield))
                          (u i 100)))
                      :title
                      "SHIELD CALIBRATION   "}
                     {:f
                      (fn [u]
                        (for [i 1 100]
                          (for [_ 1 5]
                            (coroutine.yield))
                          (u i 100)))
                      :title
                      "HYPERDRIVE CHARGE    "}] {:bar-fg (ansi.fg256 46) :interval 15 :width 28})

(section "LAUNCH AUTHORIZATION")

(let [go (vtx.confirm "INITIATE JUMP SEQUENCE?" {:affirmative "ENGAGE" :negative "ABORT"})]
  (if go
      (do
        (vtx.spin (fn []
                    (coroutine.yield "SPOOLING HYPERDRIVE...")
                    (pause 0.9)
                    (coroutine.yield "ALL STATIONS — BRACE FOR JUMP")
                    (pause 0.7)
                    (coroutine.yield "T-MINUS 3...")
                    (pause 0.6)
                    (coroutine.yield "T-MINUS 2...")
                    (pause 0.6)
                    (coroutine.yield "T-MINUS 1...")
                    (pause 0.6)
                    (coroutine.yield "ENGAGING HYPERDRIVE ━━━━━━━━━━━━━━━━━━━━")
                    (pause 1.4)
                    "JUMP COMPLETE") {:spinner "dots2" :spinner-fg (ansi.fg256 46) :title "STANDBY"})
        (print "")
        (print (vtx.gradient-text "  · · · · ·  JUMP COMPLETE — SECTOR 7-G  · · · · ·  " ["#00FF00" "#00FF87" "#00FFFF" "#00FF87" "#00FF00"]))
        (vtx.toast "ARRIVED AT DESTINATION — ALL SYSTEMS NOMINAL" {:level "success" :timeout 3}))
      (do
        (vtx.toast "JUMP SEQUENCE ABORTED — HOLDING POSITION" {:level "warn" :timeout 2})
        (print (ansi.style "
JUMP ABORTED" ansi.bold (ansi.fg256 226))))))

(section "CAPTAIN'S LOG")

(let [entry (vtx.write {:header
                        (ansi.style (.. "STARDATE " (os.date "%Y.%j") " — ENTER LOG ENTRY  [C-c C-c submit · C-q abort]") (ansi.fg256 240))
                        :height
                        5
                        :prompt
                        (ansi.style "  ▎ " (ansi.fg256 238))})]
  (when (and entry (> (# entry) 0))
    (print (vtx.style entry {:border "normal" :fg (ansi.fg256 240) :padding 1}))))

(print "")

(print (vtx.style (.. "  " (ansi.style "VTX-7 NAVIGATION SYSTEM" ansi.bold (ansi.fg256 46)) "  ·  SESSION COMPLETE  ") {:align "center" :border "normal" :fg (ansi.fg256 238) :padding 1}))

(print "")
