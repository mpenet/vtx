#include <signal.h>
#include <time.h>
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

static const luaL_Reg funcs[] = {
    {"setup_winch", l_setup_winch},
    {"resized",     l_resized},
    {"sleep",       l_sleep},
    {NULL, NULL}
};

LUALIB_API int luaopen_irx_posix_native(lua_State *L) {
    luaL_newlib(L, funcs);
    return 1;
}
