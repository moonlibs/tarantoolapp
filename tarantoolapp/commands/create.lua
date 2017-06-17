local fio = require('fio')
local yaml = require('yaml')
local fileio = require('tarantoolapp.fileio')
local util = require('tarantoolapp.util')


local default_opts = {
	workdir = '.',
	appname = 'testapp',
	version = 'scm-1',
	description = 'TestApp',
	template = 'basic'
}

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


local function get_template(info, template)
	local templates_dir = fio.pathjoin(info.rootdir, 'templates')
	local template_rootdir = fio.pathjoin(templates_dir, template)
	local template_src = fio.pathjoin(template_rootdir, 'template')
	local template_config_path = fio.pathjoin(template_rootdir, 'config.yaml')
	
	if not fileio.exists(template_rootdir) then
		error(string.format("Template '%s' not found", template))
	end
	
	if not fileio.exists(template_src) then
		error(string.format("Template '%s' is misconfigured: `template` folder not found", template))
	end
	
	local template_config = nil
	local template_options = nil
	if fileio.exists(template_config_path) then
		template_config = yaml.decode(fileio.read_file(template_config_path))
		template_options = template_config.options
	end
	
	return {
		root = template_rootdir,
		src = template_src,
		config = template_config,
		options = template_options
	}
end


local function description(info)
	return "Create new application"
end


local function help(info)
	-- TODO: parse getopt, extract template name
	-- TODO: call get_template(info, opts.template)
	-- TODO: read extra opts and add them to stdout
	return "Options:\n"
		.."\t-t --template TEMPLATE (basic)  -  template to use\n"
		.."\t-n NAME                         -  application name\n"
end


local function run(info)
	local opts = default_opts  -- temporary while no cli
	
	opts = merge_opts(opts, default_opts)
	opts.workdir = util.get_workdir(opts.workdir, true)
	
	local templ = get_template(info, opts.template)
	if templ.options ~= nil then
		merge_opts(default_opts, templ.options)
		merge_opts(opts, default_opts)
	end
	
	fileio.copydir(templ.src, opts.workdir)
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
