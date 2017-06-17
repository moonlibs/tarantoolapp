local is_dev = tonumber(os.getenv("DEV")) == 1

local listen_uri = os.getenv("LISTEN")
if listen_uri == nil then
	listen_uri = '127.0.0.1:3301'
end

box = {
	listen = listen_uri,
	slab_alloc_arena = 0.1,
	-- replication_source = { }
}

console = {
    listen = '127.0.0.1:3302'
}

app = {
	{{__appname__}} = {
		
	}
}
