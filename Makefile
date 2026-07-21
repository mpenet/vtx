FENNEL ?= fennel
FENNEL_PATH = fnl/?.fnl;fnl/?/init.fnl
FENNEL_FLAGS = --add-fennel-path "fnl/?.fnl" --add-fennel-path "fnl/?/init.fnl"

LUA_INCLUDE ?= $(shell pkg-config --cflags lua5.5 2>/dev/null || pkg-config --cflags lua-5.5 2>/dev/null || echo -I/usr/local/include)

.PHONY: demo demo-ship demo-ship-cast demo-ship-gif repl compile compile-native clean test

test:
	$(FENNEL) $(FENNEL_FLAGS) test.fnl

demo:
	$(FENNEL) $(FENNEL_FLAGS) demo.fnl

demo-ship:
	$(FENNEL) $(FENNEL_FLAGS) demo-ship.fnl

demo-ship-cast:
	asciinema rec demo-ship.cast --overwrite -i 2 \
	  --command "$(FENNEL) $(FENNEL_FLAGS) demo-ship.fnl"

demo-ship-gif:
	agg --font-dir "$(HOME)/Library/Fonts" \
	    --font-family "Berkeley Mono,TX-02 Condensed" \
	    --font-size 20 \
        --speed 2 \
	    demo-ship.cast demo-ship.gif

repl:
	$(FENNEL) $(FENNEL_FLAGS) --repl

FNL_SOURCES := $(shell find fnl -name '*.fnl' -not -path 'fnl/vtx/test/*')

compile:
	mkdir -p lua
	@for src in $(FNL_SOURCES); do \
	  base=$$(basename $$src .fnl); \
	  echo "compile $$src -> lua/$$base.lua"; \
	  $(FENNEL) $(FENNEL_FLAGS) --compile $$src > lua/$$base.lua || exit 1; \
	done

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
