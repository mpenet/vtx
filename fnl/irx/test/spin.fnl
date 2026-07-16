(local spin-m (require "irx.widget.spin"))

(local faith (require "faith"))

(fn test-spinners-dots-count []
  (faith.= 8 (# spin-m.spinners.dots)))

(fn test-spinners-dots2-count []
  (faith.= 10 (# spin-m.spinners.dots2)))

(fn test-spinners-line-count []
  (faith.= 4 (# spin-m.spinners.line)))

(fn test-spinners-bounce-count []
  (faith.= 4 (# spin-m.spinners.bounce)))

(fn test-spinners-arrow-count []
  (faith.= 8 (# spin-m.spinners.arrow)))

(fn test-spinners-dots-are-strings []
  (each [_ f (ipairs spin-m.spinners.dots)]
    (faith.= "string" (type f))))

(fn test-spinners-line-are-strings []
  (each [_ f (ipairs spin-m.spinners.line)]
    (faith.= "string" (type f))))

(fn test-spinners-dots-first-frame []
  (faith.= "string" (type (. spin-m.spinners.dots 1))))

(fn test-spinners-all-types-present []
  (faith.is spin-m.spinners.dots)
  (faith.is spin-m.spinners.dots2)
  (faith.is spin-m.spinners.line)
  (faith.is spin-m.spinners.bounce)
  (faith.is spin-m.spinners.arrow))

{:test-spinners-all-types-present test-spinners-all-types-present
 :test-spinners-arrow-count test-spinners-arrow-count
 :test-spinners-bounce-count test-spinners-bounce-count
 :test-spinners-dots-are-strings test-spinners-dots-are-strings
 :test-spinners-dots-count test-spinners-dots-count
 :test-spinners-dots-first-frame test-spinners-dots-first-frame
 :test-spinners-dots2-count test-spinners-dots2-count
 :test-spinners-line-are-strings test-spinners-line-are-strings
 :test-spinners-line-count test-spinners-line-count}
