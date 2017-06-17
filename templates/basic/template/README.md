# {{__appname__}}

_your application description_

## Commands
* `make dep` - Installs dependencies to ./libs folder
* `make run` - Runs Tarantool instance locally inside the ./tnt_{LISTEN_URI} folder. By default $LISTEN_URI = "127.0.0.1:3301"
* `make test` - Runs tests from ./t folder

## dep.py
Script that installs dependencies (luarocks for lua 5.1 is required), specified in the `meta.yaml` file.

### depy.py commands
* `./dep.py --help` - help, obviously
* `./dep.py --meta-file=./meta.yaml` - installs deps from `meta.yaml` to the system
* `./dep.py --meta-file=./meta.yaml --dev` - installs deps to the user (default is `~/.luarocks`).
* `./dep.py --meta-file=./meta.yaml --luarocks-tree=./libs` - installs deps to a specified folder (ex. libs). `make run` calls this command.


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
            └── libs/
```
You need to put a symlink `/etc/tarantool/instances.enabled/{{__appname__}}.lua -> /usr/share/{{__appname__}}/init.lua
` and you are ready to start your application by either `tarantoolctl start {{__appname__}}` or, if you're using systemd - `systemctl start tarantool@{{__appname__}}`
