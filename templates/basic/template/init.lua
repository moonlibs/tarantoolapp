#! /usr/bin/env tarantool

local soext = (jit.os == "OSX" and "dylib" or "so")
local function script_path() local fio = require "fio"; local b = debug.getinfo(2, "S").source:sub(2); local b_dir = fio.dirname(b); local lb = fio.readlink(b); while lb ~= nil do if not string.startswith(lb, '/') then lb = fio.abspath(fio.pathjoin(b_dir, lb)) end; b = lb; lb = fio.readlink(b) end return b:match("(.*/)") end
local function addpaths(dst, ...) local cwd = script_path() or fio.cwd() .. "/"; local pp = {}; for s in package[dst]:gmatch("([^;]+)") do pp[s] = 1 end; local add = ""; for _, p in ipairs({...}) do local ap = cwd .. p; if string.startswith(p, '/') then ap = p end; if not pp[ap] then add = add .. ap .. ";" end; end package[dst] = add .. package[dst] return end
addpaths('path', '?.lua', '?/init.lua', 'app/?.lua', 'app/?/init.lua', '.rocks/share/lua/5.1/?.lua', '.rocks/share/lua/5.1/?/init.lua', '.rocks/share/tarantool/?.lua', '.rocks/share/tarantool/?/init.lua')
addpaths('cpath', '.rocks/lib/lua/5.1/?.'..soext, '.rocks/lib/lua/?.'..soext, '.rocks/lib64/lua/5.1/?.'..soext, '.rocks/lib/tarantool/?.'..soext, '.rocks/lib64/tarantool/?.'..soext)

require 'strict'.on()
require 'package.reload'
local fio = require 'fio'

local conf_path = os.getenv('CONF')
if conf_path == nil then
    conf_path = '/etc/{{__name__}}/conf.lua'
end
local conf = require('config')(conf_path)

local app = require 'app'
if app ~= nil and app.init ~= nil then
    local ok, res = xpcall(
        function()
            return app.init(conf.get('app'))
        end,
        function(err)
            print(err .. '\n' .. debug.traceback())
            os.exit(1)
        end
    )
end

if tonumber(os.getenv('FG')) == 1 then
    if pcall(require('console').start) then
        os.exit(0)
    end
end
