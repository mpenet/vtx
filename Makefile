FENNEL ?= fennel
FENNEL_PATH = fnl/?.fnl;fnl/?/init.fnl
FENNEL_FLAGS = --add-fennel-path "fnl/?.fnl" --add-fennel-path "fnl/?/init.fnl"

.PHONY: demo repl compile clean test

test:
	$(FENNEL) $(FENNEL_FLAGS) test.fnl

demo:
	$(FENNEL) $(FENNEL_FLAGS) demo.fnl

repl:
	$(FENNEL) $(FENNEL_FLAGS) --repl

compile:
	mkdir -p lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/ansi.fnl   > lua/ansi.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/posix.fnl  > lua/posix.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/term.fnl   > lua/term.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/util.fnl   > lua/util.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/theme.fnl  > lua/theme.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/style.fnl   > lua/style.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/confirm.fnl > lua/confirm.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/input.fnl   > lua/input.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/write.fnl   > lua/write.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/choose.fnl  > lua/choose.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/filter.fnl  > lua/filter.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/spin.fnl     > lua/spin.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/password.fnl > lua/password.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/progress.fnl > lua/progress.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/pager.fnl    > lua/pager.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/form.fnl     > lua/form.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/table.fnl    > lua/table.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki.fnl > lua/tiki.lua

clean:
	rm -rf lua
