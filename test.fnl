(local faith (require :faith))

(faith.run [:tiki.test.ansi
            :tiki.test.util
            :tiki.test.theme
            :tiki.test.style
            :tiki.test.filter
            :tiki.test.pager
            :tiki.test.table])
