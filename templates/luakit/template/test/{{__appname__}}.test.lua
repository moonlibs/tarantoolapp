#!/usr/bin/env tarantool

local mod = require('{{__appname__}}')
local tap = require('tap')

local test = tap.test('{{__appname__}} tests')
test:plan(1)

test:test('{{__appname__}}', function(test)
    test:plan(1)
    test:is(mod.test(1), 11, "Lua function in init.lua")
end)

os.exit(test:check() == true and 0 or -1)
