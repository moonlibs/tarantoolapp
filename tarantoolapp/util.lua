local fio = require 'fio'

local function merge_tables(t, ...)
	for _, tt in ipairs({...}) do
		for _, v in ipairs(tt) do
			table.insert(t, v)
		end
	end
	return t
end

local function merge_tables_dicts(t, t2)
	for k, v in pairs(t2) do
		t[k] = v
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
	if b ~= nil then
		p = fio.pathjoin(b, p)
	end
	return fio.abspath(p)
end


local function get_workdir(workdir, create_if_not_exist)
	local fileio = require 'tarantoolapp.fileio'

	if create_if_not_exist == nil then
		create_if_not_exist = false
	end

	if not isroot(workdir) then
		local cur = fio.cwd()

		if workdir == '.' then
			workdir = cur
		else
			workdir = fio.abspath(fio.pathjoin(cur, workdir))
		end
	end

	if create_if_not_exist and not fileio.path.exists(workdir) then
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

local function printf(s, ...)
	return print(string.format(s, ...))
end

local function errorf(s, ...)
	printf(s, ...)
	os.exit(1)
end

local function table_slice(tbl, first, last, step)
	local sliced = {}

	for i = first or 1, last or #tbl, step or 1 do
	  sliced[#sliced+1] = tbl[i]
	end

	return sliced
end

return {
	merge_tables = merge_tables,
	merge_tables_dicts = merge_tables_dicts,
	copy_tabledict = copy_tabledict,
	isroot = isroot,
	slashends = slashends,
	abspath = abspath,
	get_workdir = get_workdir,
	pathinfo = pathinfo,
	dump = dump,
	printf = printf,
	errorf = errorf,
	table_slice = table_slice,
}
