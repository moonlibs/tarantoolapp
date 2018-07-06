#!/usr/bin/env tarantool

local mod = require('{{__name__}}')
local tap = require('tap')

local test = tap.test('{{__name__}} tests')
test:plan(1)

test:test('{{__name__}}', function(test)
    test:plan(1)
    test:is(mod.test(1), 11, "Lua function in init.lua")
end)

os.exit(test:check() == true and 0 or -1)
