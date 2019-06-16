all:

test:

start:
	tarantoolctl start instance_001
	tarantoolctl start instance_002

reload:
	tarantoolctl enter instance_001 <<< 'package.reload()'
	tarantoolctl enter instance_002 <<< 'package.reload()'

stop:
	tarantoolctl stop instance_001
	tarantoolctl stop instance_002

logs:
	tail -n1 -f data/*.log

dep:
	LUAROCKS_CONFIG=.luarocks-config luarocks --tree=./.rocks install --only-deps rockspecs/{{__name__}}-scm-1.rockspec

build:
	rpmbuild -ba --define "SRC_DIR ${PWD}" rpm/{{__name__}}.spec
