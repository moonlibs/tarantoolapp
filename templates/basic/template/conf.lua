box = {
	listen = os.getenv("LISTEN_URI") or "127.0.0.1:3301",
	slab_alloc_arena = 0.1,
	background = not tonumber(os.getenv("DEV")) == 1,
	
	-- snapshot_period = 3600,
	-- snapshot_count  = 2,
	
	pid_file = "tarantool.pid",
	-- logger = 'file:tarantool.log',
	-- replication_source = { }
}

-- console = {
--     listen = '127.0.0.1:3302'
-- }

app = {
	
}
