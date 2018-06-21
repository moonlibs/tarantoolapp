local bg
local logger
if os.getenv('FG') then
    bg = false
    logger = '| tee'
end

box = {
    memtx_memory = 1 * 1024 * 1024 * 1024,
    memtx_min_tuple_size = 128,
    background = bg,
    log = logger,
}

sharding = require 'etc/sharding'

app = {
}
