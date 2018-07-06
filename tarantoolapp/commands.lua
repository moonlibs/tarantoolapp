local mod = ...
local util = require 'tarantoolapp.util'
local fio = require 'fio'
-- local fun = require 'fun'

local M = {
	avail = {}
}

function M.load(name)
	local r,e = pcall(require,'tarantoolapp.commands.'..name)
	if not r then
		if e:match('not found:') then
			return false
		else
			print(e)
			os.exit(255)
		end
	else
		return e
	end
end

function M.all()
	local pathinfo = util.pathinfo()
	for _,v in pairs(fio.glob(pathinfo.dir .. '/commands/*.lua')) do
		local name = v:match('/([^/]+)%.lua')
		-- print(name)
		local r,e = pcall(require, mod .. '.' .. name)
		if r then
			M.avail[name] = e
		else
			print("Command "..name.." is not loadable: "..e)
		end
	end
	return M.avail
end

function M.list()
	local arr = {}
	for k, v in pairs(M.all()) do
		table.insert(arr, k)
	end

	return arr
end

return M