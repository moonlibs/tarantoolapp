#!/usr/bin/env tarantool

require'strict'.on()
local fiber = require 'fiber'
local under_tarantoolctl = fiber.name() == 'tarantoolctl'

local fio = require('fio');
local luaroot = debug.getinfo(1,"S")
local source  = fio.abspath(luaroot.source:match('^@(.+)'));
local symlink = fio.readlink(source);
local script_path = (symlink and fio.abspath(symlink) or source):match("^(.*/)")
local appname = script_path:match("^.*/([^/]+)/")
local instance_name = (function()
	if symlink then
		return (source:match("/([^/]+)$"):gsub('%.lua$',''))
	else
		return (source:gsub('/init%.lua$',''):match('/([^/]+)$'))
	end
end)()
rawset(_G,'who',string.format("%s#%s",appname,instance_name))

print(string.format("Starting app %s, instance %s", appname, instance_name))

local function config_path(multiinstance)
	local env_conf = os.getenv('CONF')
	if env_conf then return env_conf end
	
	if ( symlink and source:match('^/etc/') ) or source:match('^/usr/') then
		-- system wide. either /etc/{instance}/conf.lua or /etc/{{__name__}}/{instance}.lua
		if multiinstance then
			-- /etc/{{__name__}}/{instance}.lua
			return string.format("/etc/%s/%s.lua", appname, instance_name)
		else
			-- /etc/{instance}/conf.lua
			return string.format("/etc/%s/conf.lua", instance_name)
		end
	else
		-- local user
		if symlink then
			-- tarantoolctl's symlinks. look for etc/{instance}.lua
			return string.format("%s/etc/%s.lua", script_path,instance_name)
		else
			-- no symlink, search in script_path
			return script_path .. "/conf.lua"
			-- return string.format("%s/conf.lua", script_path)
		end
	end
end

local function single_config_path()
	local env_conf = os.getenv('CONF')
	if env_conf then return env_conf end
	
	if ( symlink and source:match('^/etc/') ) or source:match('^/usr/') then
		-- system wide. /etc/{appname}/conf.lua
		return string.format("/etc/%s/conf.lua", appname)
	else
		-- local user
		return string.format("%s/etc/conf.lua", script_path)
	end
end

local soext = (jit.os == "OSX" and "dylib" or "so")
local function addpaths(dst,...) local cwd = script_path; local pp = {}; for s in package[dst]:gmatch("([^;]+)") do pp[s] = 1 end; local add = ''; for _, p in ipairs({...}) do if not pp[cwd..p] then add = add..cwd..p..';'; end end;package[dst]=add..package[dst];return end
addpaths('path', '?.lua', '?/init.lua', 'app/?.lua', 'app/?/init.lua', '.rocks/share/lua/5.1/?.lua', '.rocks/share/lua/5.1/?/init.lua', '.rocks/share/tarantool/?.lua', '.rocks/share/tarantool/?/init.lua')
addpaths('cpath', '.rocks/lib/lua/5.1/?.'..soext, '.rocks/lib/lua/?.'..soext, '.rocks/lib64/lua/5.1/?.'..soext, '.rocks/lib/tarantool/?.'..soext, '.rocks/lib64/tarantool/?.'..soext)

require 'package.reload'
require 'kit'

local log = require 'log'
require 'config' {
	instance_name = instance_name,
	-- file          = config_path(),
	file          = single_config_path(),
	on_load       = function(_,cfg)
		if cfg.box.background ~= nil and not cfg.box.background and under_tarantoolctl then
			cfg.box.background = true
		end
	end;
	mkdir         = true,
}
box.once('access:v1', function()
	box.schema.user.grant('guest', 'read,write,execute', 'universe')
end)

local app = require(appname)
rawset(_G, appname, app )
if type(app) == 'table' then
	if app.destroy then
		package.reload:register(app)
	end
	if app.start then
		app.start(require('config').get('app'))
	end
end

if not box.cfg.background and not under_tarantoolctl and package.reload.count == 1 then
	require 'log'.info("Running console")
	require('console').start()
	os.exit(0)
end
