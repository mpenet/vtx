(local posix (require "vtx.posix"))

(local faith (require "faith"))

(fn test-module-loads []
  (faith.= "table" (type posix)))

(fn test-fd-constants []
  (faith.= 0 posix.STDIN_FILENO)
  (faith.= 1 posix.STDOUT_FILENO)
  (faith.= 2 posix.STDERR_FILENO))

(fn test-exports-present []
  (faith.= "function" (type posix.write))
  (faith.= "function" (type posix.sleep))
  (faith.= "function" (type posix.term-size))
  (faith.= "function" (type posix.stty-save))
  (faith.= "function" (type posix.stty-restore))
  (faith.= "function" (type posix.raw-mode-enter))
  (faith.= "function" (type posix.read-byte))
  (faith.= "function" (type posix.resized?))
  (faith.= "function" (type posix.tty-open))
  (faith.= "function" (type posix.tty-close)))

(fn test-resized-boolean []
  (faith.= "boolean" (type (posix.resized?))))

(fn test-sleep-zero-returns []
  ;; sleep 0 should return immediately, not error
  (posix.sleep 0)
  (faith.is true))

{:test-exports-present test-exports-present
 :test-fd-constants test-fd-constants
 :test-module-loads test-module-loads
 :test-resized-boolean test-resized-boolean
 :test-sleep-zero-returns test-sleep-zero-returns}
