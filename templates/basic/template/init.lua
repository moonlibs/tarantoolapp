#! /usr/bin/env tarantool

local function script_path() local fio = require'fio' local b = debug.getinfo(2, "S").source:sub(2) local lb = fio.readlink(b) if lb ~= nil then b = lb end return b:match("(.*/)") end
local function addpaths(dst, ...) local cwd = script_path() or fio.cwd() .. "/"; local pp = {}; for s in package[dst]:gmatch("([^;]+)") do pp[s] = 1 end; local add = ""; for _, p in ipairs({...}) do local ap = cwd .. p; if string.startswith(p, '/') then ap = p end; if not pp[ap] then add = add .. ap .. ";" end; end package[dst] = add .. package[dst] return end
addpaths('path', '?.lua', '?/init.lua', 'app/?.lua', 'app/?/init.lua', '.rocks/share/lua/5.1/?.lua', '.rocks/share/lua/5.1/?/init.lua', '.rocks/share/tarantool/?.lua', '.rocks/share/tarantool/?/init.lua')
addpaths('cpath', '.rocks/lib/lua/5.1/?.so', '.rocks/lib/lua/?.so', '.rocks/lib64/lua/5.1/?.so', '.rocks/lib/tarantool/?.so', '.rocks/lib64/tarantool/?.so',
                  '.rocks/lib/lua/5.1/?.dylib', '.rocks/lib/lua/?.dylib', '.rocks/lib64/lua/5.1/?.dylib', '.rocks/lib/tarantool/?.dylib', '.rocks/lib64/tarantool/?.dylib')

require 'package.reload'
local fio = require 'fio'

local conf_path = os.getenv('CONF')
if conf_path == nil then
    conf_path = '/etc/{{__appname__}}/conf.lua'
end
local conf = require('config')(conf_path)

require 'strict'.on()
local app = require 'app'
if app ~= nil and app.init ~= nil then
    local tb
    local ok, res = xpcall(
        function() 
            return app.init(conf.get('app')) 
        end, 
        function(err) 
            tb = debug.traceback(); 
            return err 
        end
    )

    if not ok then
        print(res .. '\n' .. tb)
        os.exit(1)
    end
end

if tonumber(os.getenv('FG')) == 1 then
    if pcall(require('console').start) then
        os.exit(0)
    end
end
