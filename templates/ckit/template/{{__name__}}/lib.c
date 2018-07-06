/* Example of a C submodule for Tarantool */
#include <tarantool/module.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

/* internal function */
static int
{{__name__}}_func(struct lua_State *L)
{
	if (lua_gettop(L) < 2)
		luaL_error(L, "Usage: {{__name__}}_func(a: number, b: number)");

	int a = lua_tointeger(L, 1);
	int b = lua_tointeger(L, 2);

	lua_pushinteger(L, a + b);
	return 1; /* one return value */
}

/* exported function */
LUA_API int
luaopen_{{__name__}}_lib(lua_State *L)
{
	/* result returned from require('{{__name__}}.lib') */
	lua_newtable(L);
	static const struct luaL_Reg meta [] = {
		{"func", {{__name__}}_func},
		{NULL, NULL}
	};
	luaL_register(L, NULL, meta);
	return 1;
}
/* vim: syntax=c ts=8 sts=8 sw=8 noet */
