local fio = require('fio')

local function merge_tables(t, ...)
	for _, tt in ipairs({...}) do
		for _, v in ipairs(tt) do
			table.insert(t, v)
		end
	end
	return t
end


local function copy_tabledict(t)
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = v
	end
	return t2
end


local function isroot(s)
	if s == nil or s == '' then
		return false
	else
		return string.sub(s, 1, 1) == '/'
	end
end


local function slashends(s)
	return string.sub(s, -1, -1) == '/'
end


local function abspath(p,b)
	if p == nil then return nil end
	if isroot(p) then
		return p
	end
	return fio.abspath(fio.pathjoin(b, p))
end


local function get_workdir(def, create_if_not_exist)
	local fileio = require('tarantoolapp.fileio')
	
	if create_if_not_exist == nil then
		create_if_not_exist = false
	end
	
	local workdir
	if #arg > 1 then
		error('Either 0 or 1 argument is expected')
	elseif #arg == 1 then
		workdir = arg[1]
	else
		workdir = def
	end
	
	if not isroot(workdir) then
	
		local cur = fio.cwd()
		
		if workdir == '.' then
			workdir = cur
		end
		workdir = fio.abspath(fio.pathjoin(cur, workdir))
	end
	
	-- print(fio.stat(workdir))
	if create_if_not_exist and fio.stat(workdir) == nil then
		fileio.mkdir(workdir)
	end
	
	return workdir
end

local function pathinfo()
	local info = {}
	local b = debug.getinfo(2, "S").source:sub(2);
	while b:match('/[^/]+/%.%./') do
		b = b:gsub('/[^/]+/%.%./',"/")
	end
	while b:match('/%./') do
		b = b:gsub('/%./',"/")
	end
	info.path = b
	info.name = (info.path:match("/([^/]+)$"))
	info.dir  = fio.dirname(info.path)
	return info
end

local function dump(x)
	local j = require'yaml'.new()
	j.cfg{
		encode_use_tostring = true;
	}
	return j.encode(x)
end

return {
	merge_tables = merge_tables,
	copy_tabledict = copy_tabledict,
	isroot = isroot,
	slashends = slashends,
	abspath = abspath,
	get_workdir = get_workdir,
	pathinfo = pathinfo,
	dump = dump,
}
