local util = require("luarocks.util")

local program = util.this_program()
print(program)

local cfg = require("luarocks.cfg")
for k,v in pairs(cfg) do
	print(k,v)
end
