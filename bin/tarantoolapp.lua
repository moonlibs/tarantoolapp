if _TARANTOOL == nil then
	os.exit(os.execute("tarantool "..arg[0].." "..table.concat(arg, ' ')))
end
require 'strict'.on()
package.path = '../?.lua;'..package.path

local function dump(x)
	local j = require'yaml'.new()
	j.cfg{
		encode_use_tostring = true;
	}
	return j.encode(x)
end

local util = require 'tarantoolapp.util'
local datafile = require 'datafile'
local fio = require 'fio'

local info = {}
local pathinfo = util.pathinfo()

info.script  = pathinfo.path
info.myname  = pathinfo.name:gsub('%.lua$','')
info.rootdir = pathinfo.dir:match("^(.+)/bin$")

-- print(dump(info))

local commands = require 'tarantoolapp.commands'
if #arg == 0 or arg[1]:match('^-') then
	print("Usage:\n"
		.."\t"..info.myname.." help\n"
		.."\t"..info.myname.." command [ options ]\n"
		.."\t"..info.myname.." help command\n"
	)
	os.exit(1)
end

local is_help = arg[1] == 'help'

if is_help then
	table.remove(arg,1,1)
end

local command = commands.load(arg[1])
if not command then
	print(string.format("Command %s not found. List of available commands:", arg[1]))
	for name,cmd in pairs( commands.list() ) do
		print(string.format("%s - %s", name, cmd.description and cmd.description(info) or '' ))
	end
	os.exit(1)
end

if is_help then
	print("Usage:\n"
		.."\t"..info.myname.." "..arg[1].." [ options ]\n"
	)
	if command.description then
		print(command.description(info))
	end
	if command.help then
		print(command.help(info))
	else
		print("Command "..arg[1].." have no help information")
	end
	os.exit(1)
end

command.run(info, util.table_slice(arg, 2))
