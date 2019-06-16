assert(instance_name, "instance_name is required from symlink")

-- etcd = {
-- 	prefix = '/my/tarantool/app';
-- 	instance_name = instance_name;
-- 	timeout = 1;
-- }

box = {
	background              = false,
	log_nonblock            = false,
	vinyl_memory            = 0,
	vinyl_cache             = 0,
	replication_timeout     = 1,
	replication_connect_quorum = 0,

	pid_file                = instance_name..".pid",
	memtx_dir               = "data/"..instance_name,
	wal_dir                 = "data/"..instance_name,
	log_level               = 5,
}
