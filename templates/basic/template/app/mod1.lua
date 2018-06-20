local log = require 'log'

local M = {}
local app

function M.init(config)
    app = require 'app'
    M.config = config
end

function M.destroy()

end

return M
