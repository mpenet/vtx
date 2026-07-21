(local term (require "vtx.term"))

(local faith (require "faith"))

(fn test-module-loads []
  (faith.= "table" (type term)))

(fn test-exports-present []
  (faith.= "function" (type term.write))
  (faith.= "function" (type term.writeln))
  (faith.= "function" (type term.cursor-up))
  (faith.= "function" (type term.cursor-down))
  (faith.= "function" (type term.cursor-col))
  (faith.= "function" (type term.cursor-hide))
  (faith.= "function" (type term.cursor-show))
  (faith.= "function" (type term.clear-line))
  (faith.= "function" (type term.clear-right))
  (faith.= "function" (type term.clear-rows))
  (faith.= "function" (type term.size))
  (faith.= "function" (type term.with-raw))
  (faith.= "function" (type term.read-key))
  (faith.= "function" (type term.read-byte))
  (faith.= "function" (type term.make-frame-cache))
  (faith.= "function" (type term.render-frame)))

(fn test-frame-cache-init []
  (let [c (term.make-frame-cache)]
    (faith.= nil c.last)))

(fn test-frame-cache-skips-duplicate []
  (let [c (term.make-frame-cache)]
    (term.render-frame c (fn [push]
                           (push "a")))
    (let [after-first c.last]
      (term.render-frame c (fn [push]
                             (push "a")))
      (faith.= after-first c.last)
      (term.render-frame c (fn [push]
                             (push "b")))
      (faith.= "b" c.last))))

(fn test-frame-cache-tracks-last []
  (let [c (term.make-frame-cache)]
    (term.render-frame c (fn [push]
                           (push "hello")))
    (faith.= "hello" c.last)
    (term.render-frame c (fn [push]
                           (push "world")))
    (faith.= "world" c.last)))

{:test-exports-present test-exports-present
 :test-frame-cache-init test-frame-cache-init
 :test-frame-cache-skips-duplicate test-frame-cache-skips-duplicate
 :test-frame-cache-tracks-last test-frame-cache-tracks-last
 :test-module-loads test-module-loads}
