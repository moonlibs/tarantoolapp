local spacer = require 'spacer'

--[[
spacer:space({
    name = 'object',
    format = {
        { name = 'id', type = 'unsigned' },
    },
    indexes = {
        { name = 'primary', type = 'tree', unique = true, parts = { 'id' } }
    }
})
]]--