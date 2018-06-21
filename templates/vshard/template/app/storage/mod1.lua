local bucket = require 'bucket'

local M = {}

function M.hi(bucket_id, ...)
    print(bucket_id, ...)
    return 'hello, sir'
end

return M