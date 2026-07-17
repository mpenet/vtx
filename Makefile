FENNEL ?= fennel
FENNEL_PATH = fnl/?.fnl;fnl/?/init.fnl
FENNEL_FLAGS = --add-fennel-path "fnl/?.fnl" --add-fennel-path "fnl/?/init.fnl"

LUA_INCLUDE ?= $(shell pkg-config --cflags lua5.5 2>/dev/null || pkg-config --cflags lua-5.5 2>/dev/null || echo -I/usr/local/include)

.PHONY: demo demo-ship repl compile compile-native clean test

test:
	$(FENNEL) $(FENNEL_FLAGS) test.fnl

demo:
	$(FENNEL) $(FENNEL_FLAGS) demo.fnl

demo-ship:
	$(FENNEL) $(FENNEL_FLAGS) demo-ship.fnl

repl:
	$(FENNEL) $(FENNEL_FLAGS) --repl

compile:
	mkdir -p lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/ansi.fnl   > lua/ansi.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/posix.fnl  > lua/posix.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/term.fnl   > lua/term.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/util.fnl   > lua/util.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/theme.fnl  > lua/theme.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/style.fnl   > lua/style.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/confirm.fnl > lua/confirm.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/input.fnl   > lua/input.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/write.fnl   > lua/write.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/choose.fnl  > lua/choose.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/filter.fnl  > lua/filter.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/spin.fnl     > lua/spin.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/password.fnl > lua/password.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/progress.fnl > lua/progress.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/pager.fnl    > lua/pager.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/form.fnl     > lua/form.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/gradient.fnl              > lua/gradient.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/autocomplete.fnl  > lua/autocomplete.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/file-picker.fnl   > lua/file-picker.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/key-help.fnl      > lua/key-help.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/radio.fnl         > lua/radio.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/slider.fnl        > lua/slider.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/tabs.fnl          > lua/tabs.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/tree.fnl          > lua/tree.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/date-picker.fnl   > lua/date-picker.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/dialog.fnl        > lua/dialog.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/gauge.fnl         > lua/gauge.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/multi-form.fnl    > lua/multi-form.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/sparkline.fnl     > lua/sparkline.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/viewport.fnl      > lua/viewport.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx/widget/table.fnl    > lua/table.lua
	$(FENNEL) $(FENNEL_FLAGS) --compile fnl/vtx.fnl > lua/vtx.lua

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
  SHARED_FLAGS = -bundle -undefined dynamic_lookup
else
  SHARED_FLAGS = -shared
endif

compile-native:
	mkdir -p vtx
	$(CC) $(SHARED_FLAGS) -fPIC $(LUA_INCLUDE) -o vtx/posix_native.so src/vtx_posix_native.c

clean:
	rm -rf lua vtx/posix_native.so
