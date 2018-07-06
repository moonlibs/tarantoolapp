if _TARANTOOL == nil then
	os.exit(os.execute("exec tarantool "..arg[0].." "..table.concat(arg, ' ')) == 0 and 0 or 1)
end
print('Tarantool version: ' .. _TARANTOOL)

require 'strict'.on()
package.path = '../?.lua;'..package.path

local argparse = require 'tarantoolapp.argparse'
local util = require 'tarantoolapp.util'
local commands = require 'tarantoolapp.commands'

local argparser = argparse(){
	name = "tarantoolapp",
	description = "App starter & dependency manager for Tarantool application server"
}
argparser = argparser:add_help(false)

argparser = argparser:command_target('command')
local arg_commands = {}
for command_name, command in pairs(commands.all()) do
	local cmd = argparser:command(command_name, command.description())
	command.argparse(argparser, cmd)
	if command.argparse_extra then
		arg_commands[command_name] = {
			command = command,
			arg_cmd = cmd,
		}
	end
end

for _, c in pairs(arg_commands) do
	c.command.argparse_extra(argparser, c.arg_cmd)
end
argparser = argparser:add_help(true)
local args = argparser:parse()

local command = commands.load(args.command)
if not command then
	util.printf("Command %s not found. List of available commands:", arg[1])
	for name,cmd in pairs( commands.list() ) do
		util.printf("%s - %s", name, cmd.description and cmd.description(info) or '' )
	end
	os.exit(1)
end

xpcall(
	function()
		args[args.command] = nil
		args.command = nil
		command.run(args)
	end,
	function(err)
		print(err .. '\n' .. debug.traceback())
		os.exit(1)
	end
)
