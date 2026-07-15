FENNEL ?= fennel
FENNEL_PATH = fnl/?.fnl;fnl/?/init.fnl
FENNEL_FLAGS = --add-fennel-path "fnl/?.fnl" --add-fennel-path "fnl/?/init.fnl"

LUA_INCLUDE ?= $(shell pkg-config --cflags lua5.5 2>/dev/null || pkg-config --cflags lua-5.5 2>/dev/null || echo -I/usr/local/include)

.PHONY: demo repl compile compile-native clean test

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
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/gradient.fnl              > lua/gradient.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/autocomplete.fnl  > lua/autocomplete.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/file-picker.fnl   > lua/file-picker.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/key-help.fnl      > lua/key-help.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/radio.fnl         > lua/radio.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/slider.fnl        > lua/slider.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/tabs.fnl          > lua/tabs.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/tree.fnl          > lua/tree.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/date-picker.fnl   > lua/date-picker.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/dialog.fnl        > lua/dialog.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/gauge.fnl         > lua/gauge.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/multi-form.fnl    > lua/multi-form.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/sparkline.fnl     > lua/sparkline.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/viewport.fnl      > lua/viewport.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki/widget/table.fnl    > lua/table.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/tiki.fnl > lua/tiki.lua

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
  SHARED_FLAGS = -bundle -undefined dynamic_lookup
else
  SHARED_FLAGS = -shared
endif

compile-native:
	mkdir -p tiki
	$(CC) $(SHARED_FLAGS) -fPIC $(LUA_INCLUDE) -o tiki/posix_native.so src/tiki_posix_native.c

clean:
	rm -rf lua tiki/posix_native.so
