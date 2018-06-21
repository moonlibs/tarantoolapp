local bucket = require 'bucket'

local M = {}

function M.hi(...)
    local res = bucket.vshard_call(
            {42},
            'read',
            'app.mod1.hi', ...)
    return res
end

return M