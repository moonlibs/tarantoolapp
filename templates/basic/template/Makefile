.PHONY: test run clean dep

all: test

test:
	./scripts/test.sh

clean:
	rm -rf tnt*

run:
	./scripts/run.sh
	
dep:
	./dep.py --meta-file=./meta.yaml --luarocks-tree=./libs

rpm:
	rpmbuild -ba --define="SRC_DIR $PWD" rpm/{{__appname__}}.spec