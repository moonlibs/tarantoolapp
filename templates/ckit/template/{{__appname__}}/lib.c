/* Example of a C submodule for Tarantool */
#include <tarantool/module.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

/* internal function */
static int
{{__appname__}}_func(struct lua_State *L)
{
	if (lua_gettop(L) < 2)
		luaL_error(L, "Usage: {{__appname__}}_func(a: number, b: number)");

	int a = lua_tointeger(L, 1);
	int b = lua_tointeger(L, 2);

	lua_pushinteger(L, a + b);
	return 1; /* one return value */
}

/* exported function */
LUA_API int
luaopen_{{__appname__}}_lib(lua_State *L)
{
	/* result returned from require('{{__appname__}}.lib') */
	lua_newtable(L);
	static const struct luaL_Reg meta [] = {
		{"func", {{__appname__}}_func},
		{NULL, NULL}
	};
	luaL_register(L, NULL, meta);
	return 1;
}
/* vim: syntax=c ts=8 sts=8 sw=8 noet */
