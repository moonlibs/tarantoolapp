--------------------------------------------------------------------------------
--- Example of a Lua module for Tarantool
--------------------------------------------------------------------------------

--
-- Dependencies
--

local log = require('log') -- some other Tarantool module

-- C library
local {{__appname__}}lib = require('{{__appname__}}.lib')
-- Now you can use exported C functions from '{{__appname__}}/lib.c' submodule in your code

--
-- Constants
--

-- local variables are only visible from this file
local SOME_CONSTANT = 10

--
-- Internal functions
--

-- Some internal function
local function func(a, b)
    log.info("func() called with a=%s b=%s", a, b)
    return a + b
end

--
-- Exported functions
--

-- result returned from require('{{__appname__}}')
return {
    func = func; -- pure Lua function
    cfunc = {{__appname__}}lib.func; -- C function
}
-- vim: ts=4 sts=4 sw=4 et
