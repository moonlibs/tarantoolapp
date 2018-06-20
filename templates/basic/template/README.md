# {{__appname__}}

_your application description_

## Commands
* `make dep` - Installs dependencies to ./.rocks folder
* `make run` - Runs Tarantool instance locally inside the ./.tnt/init folder.
* `make test` - Runs tests from ./t folder

## dep.lua
Script that installs dependencies (luarocks for lua 5.1 is required), specified in the `meta.yaml` file.

### dep.lua commands
* `tarantool dep.lua --meta-file ./meta.yaml` - installs deps from `meta.yaml` to the system
* `tarantool dep.lua --meta-file ./meta.yaml --tree ./.rocks` - installs deps to a specified folder (ex. .rocks). `make dep` calls this command.


### meta.yaml
`meta.yaml` can have the following sections:
* `name` - package name
* `version` - package version
* `deps` - list of paths to rockspec files or package names (each is installed using `luarocks install` command)
* `tntdeps` - list of paths to rockspec files or package names (each is installed using `tarantoolctl rocks install` command)
* `localdeps` - list of paths to local rockspec files (each is installed using `luarocks make` command). You can specify dependency in either of 2 following formats:
    - `./local/path/to/package/package.rockspec` if `*.rockspec` file is in the package root
    - `./local/path/to/package/rockspecs/package.rockspec:./local/path/to/package` - specify the package root after the colon


## Deploy
To deploy application the recommended directory structure is the following:
```
/
├── etc
│   └── {{__appname__}}
│       └── conf.lua
└── usr
    └── share
        └── {{__appname__}}
            ├── init.lua
            ├── app/
            └── .rocks/
```
You need to put a symlink `/etc/tarantool/instances.enabled/{{__appname__}}.lua -> /usr/share/{{__appname__}}/init.lua
` and you are ready to start your application by either `tarantoolctl start {{__appname__}}` or, if you're using systemd - `systemctl start tarantool@{{__appname__}}`
