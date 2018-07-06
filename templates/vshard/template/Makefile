.PHONY: test run clean dep rpm

all: test

test:
	./scripts/test.sh

clean:
	rm -rf .tnt*

router_run:
	FG=1 CONF=./etc/conf_router.lua tarantoolctl start router_1

router_boot:
	echo "vshard.router.bootstrap()" | tarantoolctl enter router_1

storage_run:
	FG=1 CONF=./etc/conf_storage.lua tarantoolctl start storage_1_a

enter:
	tarantoolctl enter router_1

start:
	CONF=./etc/conf_router.lua tarantoolctl start router_1
	CONF=./etc/conf_storage.lua tarantoolctl start storage_1_a
	@echo "Waiting cluster to start"
	@sleep 1
	echo "vshard.router.bootstrap()" | tarantoolctl enter router_1

stop:
	tarantoolctl stop router_1
	tarantoolctl stop storage_1_a

dep:
	tarantoolapp dep --meta-file ./meta.yaml --tree ./.rocks

dep-local:
	tarantoolapp dep --only localdeps

rpm:
	rpmbuild -ba --define="SRC_DIR ${PWD}" rpm/{{__name__}}.spec
