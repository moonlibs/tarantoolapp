local digest = require 'digest'

local M = {}

function M.get_bucket_id(key)
    local crc32 = digest.crc32.new()
    for _, v in ipairs(key) do
        crc32:update(tostring(v))
    end
    return 1 + math.fmod(crc32:result(), vshard.router.bucket_count())
end


function M.vshard_call(key, mode, func, ...)
    return M.vshard_call_opts(key, mode, func, {...}, {
        timeout = 1 * 60
    })
end


function M.vshard_call_opts(key, mode, func, args, opts)
    local bucket_id
    if type(key) == 'number' then
        bucket_id = key
    else
        bucket_id = M.get_bucket_id(key)
    end

    args = {bucket_id, unpack(args)}
    local r, e = vshard.router.call(bucket_id, mode, func, args, opts)
    if r == nil and e ~= nil then
        return error(e.message)
    end
    if r == false then
        return nil
    end

    return r
end

return M
