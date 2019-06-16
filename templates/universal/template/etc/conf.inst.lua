assert(instance_name, "instance_name is required from symlink")

etcd = {
	-- endpoints     = { 'http://127.0.0.1:4001','http://127.0.0.1:2379' }
	-- login         = "...",
	-- password      = "...",
	prefix        = '/my/tarantool/app';
	instance_name = instance_name;
	timeout       = 1;
}

box = {
	background              = true,
	pid_file                = instance_name..".pid",
	memtx_dir               = "/var/lib/tarantool/snaps/"..instance_name,
	wal_dir                 = "/var/lib/tarantool/xlogs/"..instance_name,
}
