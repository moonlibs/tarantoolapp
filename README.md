# tarantoolapp
App starter for Tarantool application server


## Installation

tarantoolapp is a cli tool so it is better to install it globally to system:

```
$ luarocks install https://raw.githubusercontent.com/moonlibs/tarantoolapp/master/rockspecs/tarantoolapp-scm-1.rockspec
```

## Bootstrap an application

To create a project template for application with name `myapp` in current directoty:

```
$ tarantoolapp create myapp
```

Full command is:

```
$ tarantoolapp create NAME [--template TEMPLATE] [--path PATH]
```

### Parameters to `tarantoolapp create`:

* `NAME` - Desired application name
* `TEMPLATE` - Template to use (currently available: `basic`, `luakit`, `ckit`, `vshard`)
* `PATH` - custom path where project will be created. If not specified the project is created in the current working directory under `NAME` folder

## Install dependencies

```
$ tarantoolapp dep
```

This command installs dependencies, specified in the `meta.yaml` file in current folder (luarocks and Lua 5.1 are required).

Full command is:

```
$ tarantoolapp dep [--meta-file META_FILE] [--tree TREE] [--luarocks-config LUAROCKS_CONFIG] [--only SECTION1[,SECTION2,...]]
```

### Parameters to `tarantoolapp dep`:

* `META_FILE` - path to meta.yaml file (default is ./meta.yaml)
* `TREE` - path to directory that will hold the dependencies (default is ./.rocks)
* `LUAROCKS_CONFIG` - path to luarocks config (default is $HOME/.luarocks/config.lua)
* `SECTION1,...` - install only these sections (deps, tntdeps or localdeps)


### meta.yaml
`meta.yaml` can have the following sections:
* `name` - package name
* `version` - package version
* `deps` - list of paths to rockspec files or package names (each is installed using `luarocks install` command)
* `tntdeps` - list of paths to rockspec files or package names (each is installed using `tarantoolctl rocks install` command)
* `localdeps` - list of paths to local rockspec files (each is installed using `luarocks make` command). You can specify dependency in either of 2 following formats:
    - `./local/path/to/package/package.rockspec` if `*.rockspec` file is in the package root
    - `./local/path/to/package/rockspecs/package.rockspec:./local/path/to/package` - specify the package root after the colon

## Get help

```
$ tarantoolapp help <command>
```
