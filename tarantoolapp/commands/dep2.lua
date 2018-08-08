local errno = require 'errno'
local fio = require 'fio'
local json = require 'json'
local util = require 'tarantoolapp.util'

local cfg = require 'luarocks.core.cfg'
local dir = require 'luarocks.dir'
local fetch = require 'luarocks.fetch'
local fs = require 'luarocks.fs'

local function description()
    return "Install dependencies"
end

local function argparse(argparser, cmd)
    cmd:option('-m --meta-file', 'path to meta.yaml file')
       :default('./meta.yaml')
    cmd:option('-m --lock-file', 'path to dep.lock file')
       :default('./dep.lock')
    cmd:option('-t --tree', 'path to directory that will hold the dependencies')
       :default('.rocks')
       :convert(fio.abspath)
    cmd:option('--luarocks-config', 'path to luarocks config')
       :default(fio.pathjoin(os.getenv('HOME'), '.luarocks', 'config.lua'))
    cmd:option('--only', 'install only these sections (deps, tntdeps or localdeps)')
       :args("*"):action("concat")
end

local function get_rock_hash(rockspec_url)
    local cwd = fio.cwd()
    local name = dir.base_name(rockspec_url)
    local rockspec_file, rockspec_dir = fetch.fetch_url_at_temp_dir(rockspec_url, name)
    local pkg_dir

    local handler = function(err)
        fio.chdir(cwd)
        fs.delete(rockspec_file)
        fs.delete(rockspec_dir)

        if pkg_dir ~= nil then
            fs.delete(pkg_dir)
        end
        return err
    end

    local function main()
        local rockspec = fetch.load_local_rockspec(rockspec_file, true)
        rockspec.variables = cfg.variables

        local pkg_name
        pkg_name, pkg_dir = fetch.fetch_sources(rockspec, false)
        -- print(util.dump(rockspec))
        return rockspec.source.hash
    end

    local ok, res = xpcall(main, handler)
    if not ok then error(res) end
    handler()
    return res
end

local function load_lock_file(path)
    local lockfile = fio.open(path, {'O_CREAT'}, 664) -- FIXME: permissions are wrong
    if lockfile == nil then
        util.errorf('Error opening %s: %s', path, errno.strerror())
    end

    local s = lockfile:stat()
    local lockfile_data = lockfile:read(s.size)
    if lockfile_data == '' then
        -- FIXME: does not work
        lockfile_data = '{}'
        lockfile:write(lockfile_data)
    end
    lockfile:close()
    return json.decode(lockfile_data)
end

local function run(args)
    cfg.init()
    fs.init()

    local lockfile = load_lock_file('./dep.lock')
    print(util.dump(lockfile))

    local rockspec_url = 'https://raw.githubusercontent.com/tarantool/http/master/rockspecs/http-scm-1.rockspec'
    print(get_rock_hash(rockspec_url))
end

return {
    description = description,
    argparse = argparse,
    run = run
}