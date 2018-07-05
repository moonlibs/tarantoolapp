local fio = require 'fio'
local yaml = require 'yaml'

local fileio = require 'tarantoolapp.fileio'
local util = require 'tarantoolapp.util'

local cfg


local function printf(f, ...)
    print(string.format('[%s] ' .. f, cfg.name, ...))
end

local function _string_split(s, sep)
    sep = sep or ','
    local parts = {}
    for word in string.gmatch(s, string.format('([^%s]+)', sep)) do
        table.insert(parts, word)
    end
    return parts
end

local function ensure_rocksservers(path)
    local dir = fio.dirname(path)
    if not fileio.path.is_dir(dir) then
        fileio.mkdir(dir)
    end

    if fileio.path.exists(path) then
        local f = fio.open(path)
        local data = f:read(f:stat().size)
        f:close()
        if data:match('rocks%.tarantool%.org') and data:match('rocks%.moonscript%.org') then
            printf('Already have proper rocks servers')
            return
        end
    else
        local directory = fio.dirname(path)
        if not fio.mktree(directory) then
            printf('Error while creating %s: %s', directory, errno.strerror())
            os.exit(1)
        end
    end
    printf("Patch %s with proper rocks servers", path)
    local fh = fio.open(path, {'O_CREAT', 'O_APPEND', 'O_RDWR'}, 0664)
    fh:write('\nrocks_servers = {[[http://rocks.tarantool.org/]], [[https://rocks.moonscript.org]]}\n')
    fh:close()
end


local function execute(cmd)
    local raw_cmd = table.concat(cmd, ' ')
    printf("%s...", raw_cmd)
    local res = os.execute('exec ' .. raw_cmd)
    if res ~= 0 then
        error(string.format('[%s] %s failed', cfg.name, raw_cmd))
    end
    return res
end


local function cmd_luarocks(subcommand, dep, tree)
    assert(subcommand ~= nil, 'subcommand is required')
    assert(dep ~= nil, 'dep is required')

    local cmd = {'luarocks', subcommand, dep}
    if tree then
        table.insert(cmd, '--tree='..tree)
    end
    return execute(cmd)
end


local function cmd_tarantoolctl(subcommand, dep, tree)
    assert(subcommand ~= nil, 'subcommand is required')
    assert(dep ~= nil, 'dep is required')

    local cmd = {'tarantoolctl', 'rocks', subcommand, dep}
    return execute(cmd)
end


local function _gencmd(command, subcommand)
    return function(dep, tree)
        return command(subcommand, dep, tree)
    end
end

local luarocks_install = _gencmd(cmd_luarocks, 'install')
local luarocks_remove = _gencmd(cmd_luarocks, 'remove')
local luarocks_make = _gencmd(cmd_luarocks, 'make')
local tarantoolctl_install = _gencmd(cmd_tarantoolctl, 'install')

local function description(info)
	return "Install dependencies"
end

local function help(info)
	-- TODO: parse getopt, extract template name
	-- TODO: call get_template(info, opts.template)
	-- TODO: read extra opts and add them to stdout
	return "Options:\n"
		.."\t--luarocks-config CONFIG        -  path to luarocks config (default is $HOME/.luarocks/config.lua)\n"
		.."\t--meta-file META_FILE           -  path to meta.yaml file (default is ./meta.yaml)\n"
		.."\t--tree TREE                     -  path to directory that will hold the dependencies (default is ./.rocks)\n"
		.."\t--only SECTION1[,SECTION2,...]  -  install only these sections (deps, tntdeps or localdeps)\n"
end

local function run(info, args)
    local luaroot = debug.getinfo(1, 'S')
    local source = fio.abspath(luaroot.source:match('^@(.+)'))
    local appname = fio.basename(fio.dirname(source))

    local parsed_args = {
        ['--luarocks-config'] = fio.pathjoin(os.getenv('HOME'), '.luarocks', 'config.lua'),
        ['--meta-file']       = './meta.yaml',
        ['--tree']            = '.rocks',
        ['--only']            = '',
    }

    if #args % 2 ~= 0 then
		util.errorf('[create] Uneven args')
	end

    for i = 1,#args/2 do parsed_args[ args[i*2-1] ] = args[i*2] end

    local meta_path = parsed_args['--meta-file']
    assert(meta_path ~= '', 'meta file is required')

    print('Using the following options:\n' .. yaml.encode(parsed_args))

    local meta_file = fio.open(fio.abspath(meta_path))
    if meta_file == nil then
        util.errorf('Meta file %s does not exist', fio.abspath(meta_path))
    end
    local metatext = meta_file:read(meta_file:stat().size)
    local tree = fio.abspath(parsed_args['--tree'])
    local only_sections
    if parsed_args['--only'] ~= '' then
        only_sections = {}
        for _, s in ipairs(_string_split(parsed_args['--only'])) do
            only_sections[s] = true
        end
    end

    cfg = metatext:match('^%s*%{') and require 'json'.decode(metatext) or yaml.decode(metatext)

    cfg.name = cfg.name or appname
    assert(cfg.name, 'Name must be defined')

    ensure_rocksservers(parsed_args['--luarocks-config'])

    printf('Installing dependencies...')
    local deps = cfg.deps or {}
    local tnt_deps = cfg.tnt_deps or cfg.tntdeps or {}
    local local_deps = cfg.local_deps or cfg.localdeps or {}

    if only_sections == nil or only_sections.deps then
        for _, dep in ipairs(deps) do
            printf("Installing dep '%s'", dep)
            luarocks_install(dep, tree)
            printf("Installed dep '%s'\n\n", dep)
        end
    end

    if only_sections == nil or only_sections.tntdeps or only_sections.tnt_deps then
        for _, dep in ipairs(tnt_deps) do
            printf("Installing tarantool dep '%s'", dep)
            tarantoolctl_install(dep, tree)
            printf("Installed tarantool dep '%s'\n\n", dep)
        end
    end

    if only_sections == nil or only_sections.localdeps or only_sections.local_deps then
        local cwd = fio.cwd()
        for _, dep in ipairs(local_deps) do
            local dep_root
            local dep_info = _string_split(dep, ':')
            if #dep_info > 1 then
                dep = dep_info[1]
                dep_root = dep_info[2]
            else
                dep_root = fio.dirname(dep)
            end
            printf("Installing local dep '%s' with root at '%s'", dep, dep_root)
            dep = fio.abspath(dep)
            dep_root = fio.abspath(dep_root)

            fio.chdir(dep_root) -- local rocks must be installed from within the project root
            local ok, res = pcall(luarocks_remove, dep, tree)
            if not ok then
                printf(res)
            end

            luarocks_make(dep, tree)
            fio.chdir(cwd)
            printf("Installed local dep '%s'\n\n", dep)
        end
    end
    printf('Done.')
end

return {
	description = description,
	help = help,
	run = run,
}
