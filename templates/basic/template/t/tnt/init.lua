local fio = require 'fio'
local errno = require 'errno'
local yaml = require 'yaml'
local log = require 'log'

local dir = os.getenv('TNT_FOLDER')
local cleanup = false

if dir == nil then
    dir = fio.tempdir()
    cleanup = true
end

local function compare_versions(expected, version)
    -- from tarantool/queue compat.lua
    local fun = require 'fun'
    local iter, op  = fun.iter, fun.operator

    local function split(self, sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) table.insert(fields, c) end)
        return fields
    end

    local function reducer(res, l, r)
        if res ~= nil then
            return res
        end
        if tonumber(l) == tonumber(r) then
            return nil
        end
        return tonumber(l) > tonumber(r)
    end

    local function split_version(version_string)
        local vtable  = split(version_string, '.')
        local vtable2 = split(vtable[3],  '-')
        vtable[3], vtable[4] = vtable2[1], vtable2[2]
        return vtable
    end

    local function check_version(expected, version)
        version = version or _TARANTOOL
        if type(version) == 'string' then
            version = split_version(version)
        end
        local res = iter(version):zip(expected):reduce(reducer, nil)

        if res or res == nil then res = true end
        return res
    end

    return check_version(expected, version)
end

local function tnt_prepare(cfg_args)
    cfg_args = cfg_args or {}
    local files = fio.glob(fio.pathjoin(dir, '*'))
    for _, file in pairs(files) do
        if fio.basename(file) ~= 'tarantool.log' then
            log.info("skip removing %s", file)
            fio.unlink(file)
        end
    end

    if compare_versions({1, 7, 3}, _TARANTOOL) then
        cfg_args['memtx_dir']  = dir
        cfg_args['vinyl_dir']  = dir
        cfg_args['log']        = "file:" .. fio.pathjoin(dir, 'tarantool.log')
    else
        cfg_args['snap_dir']   = dir
        cfg_args['vinyl']      = {}
        cfg_args['logger']     = fio.pathjoin(dir, 'tarantool.log')
    end
    cfg_args['wal_dir']    = dir

    box.cfg(cfg_args)
end

return {
    finish = function(code)
        local files = fio.glob(fio.pathjoin(dir, '*'))
        for _, file in pairs(files) do
            if fio.basename(file) == 'tarantool.log' and not cleanup then
                log.info("skip removing %s", file)
            else
                log.info("remove %s", file)
                fio.unlink(file)
            end
        end
        if cleanup then
            log.info("rmdir %s", dir)
            fio.rmdir(dir)
        end
    end,

    dir = function()
        return dir
    end,

    cleanup = function()
        return cleanup
    end,

    logfile = function()
        return fio.pathjoin(dir, 'tarantool.log')
    end,

    log = function()
        local fh = fio.open(fio.pathjoin(dir, 'tarantool.log'), 'O_RDONLY')
        if fh == nil then
            box.error(box.error.PROC_LUA, errno.strerror())
        end

        local data = fh:read(16384)
        fh:close()
        return data
    end,

    cfg = tnt_prepare
}
