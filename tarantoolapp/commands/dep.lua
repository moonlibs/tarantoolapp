local errno = require 'errno'
local fio = require 'fio'
local yaml = require 'yaml'

local fileio = require 'tarantoolapp.fileio'
local util = require 'tarantoolapp.util'

local cfg


local function printf(f, ...)
    print(string.format('[%s] ' .. f, cfg.name, ...))
end

local function errorf(f, ...)
    print(string.format('[%s] ' .. f, cfg.name, ...))
    os.exit(1)
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
        if not f then
            errorf("Failed to open file %s: %s", path, errno.strerror())
        end
        local data = f:read(f:stat().size)
        f:close()
        if data:match('rocks%.tarantool%.org') and data:match('rocks%.moonscript%.org') then
            printf('Already have proper rocks servers')
            return
        end
    else
        local directory = fio.dirname(path)
        if not fio.mktree(directory) then
            errorf('Error while creating %s: %s', directory, errno.strerror())
        end
    end
    printf("Patch %s with proper rocks servers", path)
    local fh = fio.open(path, {'O_CREAT', 'O_APPEND', 'O_RDWR'}, 0664)
    if not fh then
        errorf("Failed to open file %s: %s", path, errno.strerror())
    end
    fh:write('\nrocks_servers = {[[http://rocks.tarantool.org/]], [[https://rocks.moonscript.org]]}\n')
    fh:close()
end


local function execute(cmd)
    local raw_cmd = table.concat(cmd, ' ')
    printf("%s...", raw_cmd)
    local res = os.execute('exec ' .. raw_cmd)
    if res ~= 0 then
        errorf('%s failed', raw_cmd)
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

local function description()
    return "Install dependencies"
end

local function argparse(argparser, cmd)
    cmd:option('-m --meta-file', 'path to meta.yaml file')
       :default('./meta.yaml')
    cmd:option('-t --tree', 'path to directory that will hold the dependencies')
       :default('.rocks')
       :convert(fio.abspath)
    cmd:option('--luarocks-config', 'path to luarocks config')
       :default(fio.pathjoin(os.getenv('HOME'), '.luarocks', 'config.lua'))
    cmd:option('--only', 'install only these sections (deps, tntdeps or localdeps)')
       :args("*"):action("concat")
end

local function run(args)
    local luaroot = debug.getinfo(1, 'S')
    local source = fio.abspath(luaroot.source:match('^@(.+)'))
    local appname = fio.basename(fio.dirname(source))

    assert(args.meta_file ~= '', 'meta file is required')

    args.meta_file = fio.abspath(args.meta_file)
    local meta_file = fio.open(args.meta_file)
    if meta_file == nil then
        errorf('Meta file %s does not exist', args.meta_file)
    end
    local metatext = meta_file:read(meta_file:stat().size)
    local tree = fio.abspath(args.tree)

    local only_sections
    if args.only and #args.only > 0 then
        only_sections = {}
        for _, s in ipairs(args.only) do
            if s == 'local_deps' or s == 'localdeps' or s == 'local' then
                only_sections.localdeps = true
            elseif s == 'tnt_deps' or s == 'tntdeps' or s == 'tnt' or s == 'tarantool' then
                only_sections.tntdeps = true
            elseif s == 'deps' then
                only_sections.deps = true
            end
        end
    end
    args.only = only_sections
    print('Using the following options:\n' .. yaml.encode(args))

    cfg = metatext:match('^%s*%{') and require 'json'.decode(metatext) or yaml.decode(metatext)

    cfg.name = cfg.name or appname
    assert(cfg.name, 'Name must be defined')

    ensure_rocksservers(args.luarocks_config)

    printf('Installing dependencies...')
    local deps = cfg.deps or {}
    local tnt_deps = cfg.tnt_deps or cfg.tntdeps or {}
    local local_deps = cfg.local_deps or cfg.localdeps or {}

    if args.only == nil or args.only.deps then
        for _, dep in ipairs(deps) do
            printf("Installing dep '%s'", dep)
            luarocks_install(dep, tree)
            printf("Installed dep '%s'\n\n", dep)
        end
    end

    if args.only == nil or args.only.tntdeps then
        for _, dep in ipairs(tnt_deps) do
            printf("Installing tarantool dep '%s'", dep)
            tarantoolctl_install(dep, tree)
            printf("Installed tarantool dep '%s'\n\n", dep)
        end
    end

    if args.only == nil or args.only.localdeps then
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
    argparse = argparse,
    run = run,
}
