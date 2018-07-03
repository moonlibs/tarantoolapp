local datafile = require 'datafile'
local errno = require 'errno'
local fio = require 'fio'
local yaml = require 'yaml'

local fileio = require 'tarantoolapp.fileio'
local util = require 'tarantoolapp.util'


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
	require 'strict'.off()
	local restytempl = require 'resty.template'

	local context = {
		__appname__ = opts.appname,
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


local function get_template(info, template)
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


local function description(info)
	return "Create new application"
end


local function help(info)
	-- TODO: parse getopt, extract template name
	-- TODO: call get_template(info, opts.template)
	-- TODO: read extra opts and add them to stdout
	return "Options:\n"
		.."\t NAME                        -  project name\n"
		.."\t--template TEMPLATE          -  template to use (default is basic). Available templates: (basic, luakit, ckit)\n"
		.."\t--path PATH                  -  path to directory where to setup project (default is ./NAME)\n"
end


local function run(info, args)
	local appname = args[1]

	if appname == nil then
		util.errorf('[create] project name must be specified')
	end

	table.remove(args, 1, 1)

	local parsed_args = {
        ['--template'] = 'basic',
        ['--path']     = fio.pathjoin('.', appname),
	}
	if #args % 2 ~= 0 then
		util.errorf('[create] Uneven args')
	end

    for i = 1,#args/2 do parsed_args[ args[i*2-1] ] = args[i*2] end

	local opts = {}
	if appname == nil then
		util.errorf('project name must be provided as the 1st argument as tarantoolapp create <NAME>')
	end
	opts.template = parsed_args['--template']
	opts.appname = appname

	local path = fio.abspath(parsed_args['--path'])
	if fileio.path.exists(path) then
		util.errorf('Project "%s" already exists under path %s', appname, path)
	end

	opts = merge_opts(opts, default_opts)

	local templ = get_template(info, opts.template)
	if templ.options ~= nil then
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

	util.printf('Project "%s" structure is created in: %s', opts.appname, path)
end


return {
	description = description,
	help = help,
	run = run,
}
