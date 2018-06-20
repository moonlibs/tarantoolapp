#!/usr/bin/env tarantool

local mod = require('{{__appname__}}')
local tap = require('tap')

local test = tap.test('{{__appname__}} tests')
test:plan(1)

test:test('mod', function(test)
    test:plan(2)
    test:is(mod.func(10, 15), 25, "Lua function")
    test:is(mod.cfunc(10, 15), 25, "Lua/C function")
end)

os.exit(test:check() == true and 0 or -1)
