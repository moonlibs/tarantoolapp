local datafile = require 'datafile'
local errno = require 'errno'
local fio = require 'fio'
local yaml = require 'yaml'

local fileio = require 'tarantoolapp.fileio'
local util = require 'tarantoolapp.util'

local default_opts = {
	name = 'myapp',
	version = 'scm-1',
	description = 'Tarantool App',
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
	require 'strict'.off()
	local restytempl = require 'resty.template'

	local context = {
		__name__ = opts.name,
		__version__ = opts.version,
	}
	context = util.merge_tables_dicts(context, opts)

	local t = restytempl.compile(s, 'no-cache', true)
	local rendered = t(context)
	require 'strict'.on()
	return rendered
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

local function list_templates()
	local templates_dir, err = datafile.path('templates')
	if err ~= nil then
		error(err)
	end
	local dirs = fileio.listdir(templates_dir, nil, false)
	local templates = {}
	for _, el in ipairs(dirs) do
		table.insert(templates, el.name)
	end
	return templates
end


local function get_template(template)
	if template == nil then
		return nil
	end
	local templates_dir = datafile.path('templates')
	local template_rootdir = fio.pathjoin(templates_dir, template)
	local template_src = fio.pathjoin(template_rootdir, 'template')
	local template_config_path = fio.pathjoin(template_rootdir, 'config.yaml')
	local hooks = {
		post_gen = fio.pathjoin(template_rootdir, 'hooks', 'post_gen.lua')
	}

	if not fileio.path.exists(template_rootdir) then
		util.errorf("Template '%s' not found", template)
	end

	if not fileio.path.exists(template_src) then
		util.errorf("Template '%s' is misconfigured: `template` folder not found", template)
	end

	local template_config = nil
	local template_options = nil
	if fileio.path.exists(template_config_path) then
		template_config = yaml.decode(fileio.read_file(template_config_path))
		template_options = template_config.options
	end

	local compiled_hooks = {}
	for k, v in pairs(hooks) do
		if fileio.path.exists(v) then
			local v, err = loadfile(v)
			if v == nil then
				error(string.format("Error compiling hook %s: \n%s", k, err))
			end
			local wrapper = (function(v)
				return function(project_opts)
					local context = {
						require = require,
						project_opts = project_opts,
						_TARANTOOL = _TARANTOOL,
						print = print,
					}
					setfenv(v, context)
					return v()
				end
			end)(v)

			compiled_hooks[k] = wrapper
		end
	end

	return {
		root = template_rootdir,
		src = template_src,
		config = template_config,
		options = template_options,
		hooks = compiled_hooks,
	}
end


local function description()
	return "Create new application"
end

local function argparse(parser, cmd)
	local templates = table.concat(list_templates(), ', ')
	cmd:argument('name', 'Desired project name')
	cmd:option('-t --template', string.format('template to use. Available templates: (%s)', templates))
	   :default(default_opts.template)
	cmd:option('-p --path', 'path to directory where to setup project (default is ./{your_project_name})')
	cmd:option('--description', 'Project description')
	   :default(default_opts.description)
	cmd:option('--version', 'Project version')
	   :default(default_opts.version)
	cmd:add_help(false)
end

local function argparse_extra(parser, cmd)
	local ok, args, err = parser:pparse_known_anything()
	if args.template == nil then
		args.template = default_opts.template
	end
	-- local args = {}
	local templ_options = {}
	local templ = get_template(args.template)
	if templ and templ.options then
		for k, v in pairs(templ.options) do
			local name = '--'..args.template..'_'..k
			local o
			if type(v) == 'boolean' then
				o = cmd:option(name, 'y/n')
				       :default(v)
				       :convert(function(val) return val == 'y' or val == 'Y' end)
			elseif type(v) == 'number' then
				o = cmd:option(name, 'number value')
				       :default(v)
				       :convert(tonumber)
			elseif type(v) == 'string' then
				o = cmd:option(name, 'string value')
				       :default(v)
				       :convert(tostring)
			else
				util.errorf('unknown type for template option: %s', type(v))
			end

			if o ~= nil then
				table.insert(templ_options, o)
			end
		end
	end
	if #templ_options > 0 then
		cmd:group("Template-specific options", unpack(templ_options))
	end
	cmd:add_help(true)
end


local function run(args)
	if args.path == nil then
		args.path = './'..args.name
	end

	local opts = {}
	opts.template = args.template
	opts.name = args.name

	local path = fio.abspath(args.path)
	if fileio.path.exists(path) then
		util.errorf('Project "%s" already exists under path %s', args.name, path)
	end

	opts = merge_opts(opts, default_opts)
	local templ = get_template(opts.template)
	if templ.options ~= nil then
		for k, v in pairs(args) do -- searching for template-specific options
			local prefix = opts.template .. '_'
			if string.startswith(k, prefix) then
				k = string.gsub(k, prefix, '')
			end
			opts[k] = v
		end
		merge_opts(default_opts, templ.options)
		merge_opts(opts, default_opts)
	end
	print(util.dump(opts))

	util.printf("Using %s template in working directory %s", opts.template, path)
	if not fileio.path.exists(path) then
		if not fio.mktree(path) then
            util.errorf('Error while creating %s: %s', path, errno.strerror())
        end
	end
	fileio.copydir(templ.src, path)
	local files = fileio.listdir(path, false)
	for _, f in ipairs(files) do
		local fmode, fpath = f.mode, f.path
		if fmode == 'file' then
			render_file(fpath, opts)
		end
		render_name(fpath, opts)
	end

	if templ.hooks.post_gen then
		local cwd = fio.cwd()
		fio.chdir(path)
		templ.hooks.post_gen(opts)
		fio.chdir(cwd)
	end

	util.printf('Project "%s" structure is created in: %s', opts.name, path)
end


return {
	description = description,
	argparse = argparse,
	argparse_extra = argparse_extra,
	run = run,
}
