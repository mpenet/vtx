#include <signal.h>
#include <time.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include <string.h>
#include <wchar.h>
#include <locale.h>
#include <lua.h>
#include <lauxlib.h>

static volatile sig_atomic_t winch_flag = 0;
static void winch_handler(int sig) { (void)sig; winch_flag = 1; }

static int l_setup_winch(lua_State *L) {
    struct sigaction sa;
    sa.sa_handler = winch_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;  /* no SA_RESTART: allows EINTR to interrupt blocking reads */
    sigaction(SIGWINCH, &sa, NULL);
    return 0;
}

/* Terminal state restoration on fatal signals.
   Saved when raw mode is entered; restored on SIGINT/TERM/HUP/QUIT before
   chaining to any previously-installed handler (or default action). */
static struct termios saved_termios;
static int saved_termios_valid = 0;
static struct sigaction prev_int, prev_term, prev_hup, prev_quit;

static void restore_termios(void) {
    if (!saved_termios_valid) return;
    int fd = open("/dev/tty", O_WRONLY | O_NOCTTY);
    if (fd >= 0) {
        tcsetattr(fd, TCSAFLUSH, &saved_termios);
        /* re-show cursor in case widget hid it */
        const char show[] = "\033[?25h";
        write(fd, show, sizeof(show) - 1);
        close(fd);
    }
}

static void chain(int sig, struct sigaction *prev) {
    if (prev->sa_handler == SIG_DFL) {
        signal(sig, SIG_DFL);
        raise(sig);
    } else if (prev->sa_handler == SIG_IGN) {
        /* ignored; do nothing */
    } else if (prev->sa_flags & SA_SIGINFO) {
        /* siginfo handler — call with minimal info */
        if (prev->sa_sigaction) prev->sa_sigaction(sig, NULL, NULL);
    } else if (prev->sa_handler) {
        prev->sa_handler(sig);
    } else {
        signal(sig, SIG_DFL);
        raise(sig);
    }
}

static void handle_int(int sig)  { restore_termios(); chain(sig, &prev_int);  }
static void handle_term(int sig) { restore_termios(); chain(sig, &prev_term); }
static void handle_hup(int sig)  { restore_termios(); chain(sig, &prev_hup);  }
static void handle_quit(int sig) { restore_termios(); chain(sig, &prev_quit); }

static int l_install_fatal_handlers(lua_State *L) {
    struct sigaction sa;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sa.sa_handler = handle_int;
    sigaction(SIGINT, &sa, &prev_int);
    sa.sa_handler = handle_term;
    sigaction(SIGTERM, &sa, &prev_term);
    sa.sa_handler = handle_hup;
    sigaction(SIGHUP, &sa, &prev_hup);
    sa.sa_handler = handle_quit;
    sigaction(SIGQUIT, &sa, &prev_quit);
    return 0;
}

static int l_resized(lua_State *L) {
    int v = winch_flag;
    winch_flag = 0;
    lua_pushboolean(L, v);
    return 1;
}

static int l_sleep(lua_State *L) {
    double s = luaL_checknumber(L, 1);
    struct timespec ts;
    ts.tv_sec  = (time_t)s;
    ts.tv_nsec = (long)((s - ts.tv_sec) * 1e9);
    nanosleep(&ts, NULL);
    return 0;
}

static int tty_fd = -1;

static int get_tty_fd(void) {
    if (tty_fd < 0) {
        tty_fd = open("/dev/tty", O_RDONLY | O_NOCTTY | O_CLOEXEC);
    }
    return tty_fd;
}

static int l_term_size(lua_State *L) {
    struct winsize ws;
    int fd = get_tty_fd();
    if (fd < 0) return 0;
    if (ioctl(fd, TIOCGWINSZ, &ws) == 0 && ws.ws_row > 0 && ws.ws_col > 0) {
        lua_pushinteger(L, ws.ws_row);
        lua_pushinteger(L, ws.ws_col);
        return 2;
    }
    return 0;
}

static int l_stty_save(lua_State *L) {
    struct termios t;
    int fd = get_tty_fd();
    if (fd < 0) return 0;
    if (tcgetattr(fd, &t) != 0) return 0;
    lua_pushlstring(L, (const char *)&t, sizeof(t));
    return 1;
}

static int l_stty_restore(lua_State *L) {
    size_t len;
    const char *data = luaL_checklstring(L, 1, &len);
    if (len != sizeof(struct termios)) return 0;
    int fd = get_tty_fd();
    if (fd < 0) return 0;
    struct termios t;
    memcpy(&t, data, sizeof(t));
    tcsetattr(fd, TCSAFLUSH, &t);
    return 0;
}

static int l_raw_mode_enter(lua_State *L) {
    struct termios t;
    int fd = get_tty_fd();
    if (fd < 0) return 0;
    if (tcgetattr(fd, &t) != 0) return 0;
    /* stash for signal-driven restore */
    saved_termios = t;
    saved_termios_valid = 1;
    cfmakeraw(&t);
    t.c_cc[VMIN] = 1;
    t.c_cc[VTIME] = 1;
    tcsetattr(fd, TCSAFLUSH, &t);
    return 0;
}

static locale_t ctype_locale = (locale_t)0;
static int l_wcwidth(lua_State *L) {
    if (ctype_locale == (locale_t)0) {
        ctype_locale = newlocale(LC_CTYPE_MASK, "", (locale_t)0);
        if (ctype_locale == (locale_t)0) {
            /* fallback: no locale created; wcwidth will use current global locale */
            lua_Integer cp = luaL_checkinteger(L, 1);
            lua_pushinteger(L, wcwidth((wchar_t)cp));
            return 1;
        }
    }
    lua_Integer cp = luaL_checkinteger(L, 1);
    locale_t prev = uselocale(ctype_locale);
    int w = wcwidth((wchar_t)cp);
    uselocale(prev);
    lua_pushinteger(L, w);
    return 1;
}

static const luaL_Reg funcs[] = {
    {"setup_winch",           l_setup_winch},
    {"resized",               l_resized},
    {"sleep",                 l_sleep},
    {"term_size",             l_term_size},
    {"stty_save",             l_stty_save},
    {"stty_restore",          l_stty_restore},
    {"raw_mode_enter",        l_raw_mode_enter},
    {"install_fatal_handlers", l_install_fatal_handlers},
    {"wcwidth",               l_wcwidth},
    {NULL, NULL}
};

LUALIB_API int luaopen_vtx_posix_native(lua_State *L) {
    luaL_newlib(L, funcs);
    return 1;
}
