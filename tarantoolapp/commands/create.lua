local fio = require('fio')
local yaml = require('yaml')
local fileio = require('tarantoolapp.fileio')
local util = require('tarantoolapp.util')


local default_opts = {
	workdir = '.',
	appname = 'testapp',
	version = 'scm-1',
	description = 'TestApp',
	template_name = 'basic'
}

local function description(info)
	return "Create new application"
end

local function help(info)
	return "Options:\n"
		.."\t-t --template TEMPLATE (basic)  -  template to use\n"
		.."\t-n NAME                         -  application name\n"
end

local function merge_opts(opts, default_opts)
	for k, v in pairs(default_opts) do
		if opts[k] == nil then
			opts[k] = v
		end
	end
	
	return opts
end

local function render(s, opts)
	local template_opts = {}
	
	s = string.gsub(s, "{{__appname__}}", opts.appname)
	s = string.gsub(s, "{{__version__}}", opts.version)
	
	for k, v in pairs(opts) do
		s = string.gsub(s, "{{" .. k .. "}}", v)
	end
	return s
end


local function render_name(filepath, opts)
	local filename = fio.basename(filepath)
	local filedir = fio.dirname(filepath)
	
	local new_filename = render(filename, opts)
	local new_filepath = fio.pathjoin(filedir, new_filename)
	fio.rename(filepath, new_filepath)
	return new_filepath
end


local function render_file(filepath, opts)
	local s = fileio.read_file(filepath)
	local new_s = render(s, opts)
	
	local src_mode = fio.stat(filepath).mode
	
	local fh = fio.open(filepath, {'O_WRONLY', 'O_TRUNC'}, src_mode)
	if not fh then
		error(string.format("Failed to open file %s: %s", filepath, errno.strerror()))
	end
	
	fh:write(new_s)
	fh:close()
end


local function run(info)
	local opts = default_opts  -- temporary while no cli
	
	opts = merge_opts(opts, default_opts)
	opts.workdir = util.get_workdir(opts.workdir)
	
	local templates_dir = fio.pathjoin(rootdir, 'templates')
	local template_rootdir = fio.pathjoin(templates_dir, opts.template_name)
	local template_src = fio.pathjoin(template_rootdir, 'template')
	local template_config_path = fio.pathjoin(template_rootdir, 'config.yaml')
	
	if fio.stat(template_rootdir) == nil then
		error(string.format("Template '%s' not found", opts.template_name))
	end
	
	if fio.stat(template_src) == nil then
		error(string.format("Template '%s' is misconfigured: `template` folder not found", opts.template_name))
	end
	
	if fio.stat(template_config_path) ~= nil then
		local template_config = yaml.decode(fileio.read_file(template_config_path))
		if template_config.options ~= nil then
			merge_opts(default_opts, template_config.options)
			merge_opts(opts, default_opts)
		end
	end
	
	fileio.copydir(template_src, opts.workdir)
	local files = fileio.listdir(opts.workdir)
	for _, f in ipairs(files) do
		local fmode, fpath = f.mode, f.path
		if fmode == 'file' then
			render_file(fpath, opts)
		end
		render_name(fpath, opts)
	end
	
end


return {
	description = description,
	help = help,
	run = run,
}
