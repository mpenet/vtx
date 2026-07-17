(local date-m (require "vtx.widget.date-picker"))

(local faith (require "faith"))

(fn test-days-in-month-jan []
  (faith.= 31 (date-m.days-in-month 2024 1)))

(fn test-days-in-month-feb-leap []
  (faith.= 29 (date-m.days-in-month 2024 2)))

(fn test-days-in-month-feb-non-leap []
  (faith.= 28 (date-m.days-in-month 2023 2)))

(fn test-days-in-month-feb-century []
  (faith.= 28 (date-m.days-in-month 1900 2)))

(fn test-days-in-month-feb-400 []
  (faith.= 29 (date-m.days-in-month 2000 2)))

(fn test-days-in-month-april []
  (faith.= 30 (date-m.days-in-month 2024 4)))

(fn test-days-in-month-dec []
  (faith.= 31 (date-m.days-in-month 2024 12)))

(fn test-clamp-day-valid []
  (faith.= 15 (date-m.clamp-day 2024 1 15)))

(fn test-clamp-day-over-feb []
  (faith.= 28 (date-m.clamp-day 2023 2 31)))

(fn test-clamp-day-over-april []
  (faith.= 30 (date-m.clamp-day 2024 4 31)))

(fn test-clamp-day-under []
  (faith.= 1 (date-m.clamp-day 2024 3 0)))

(fn test-clamp-day-leap []
  (faith.= 29 (date-m.clamp-day 2024 2 29)))

(fn test-clamp-day-non-leap []
  (faith.= 28 (date-m.clamp-day 2023 2 29)))

{:test-clamp-day-leap test-clamp-day-leap
 :test-clamp-day-non-leap test-clamp-day-non-leap
 :test-clamp-day-over-april test-clamp-day-over-april
 :test-clamp-day-over-feb test-clamp-day-over-feb
 :test-clamp-day-under test-clamp-day-under
 :test-clamp-day-valid test-clamp-day-valid
 :test-days-in-month-april test-days-in-month-april
 :test-days-in-month-dec test-days-in-month-dec
 :test-days-in-month-feb-400 test-days-in-month-feb-400
 :test-days-in-month-feb-century test-days-in-month-feb-century
 :test-days-in-month-feb-leap test-days-in-month-feb-leap
 :test-days-in-month-feb-non-leap test-days-in-month-feb-non-leap
 :test-days-in-month-jan test-days-in-month-jan}
