# tarantoolapp
App starter for Tarantool application server


## Installation

tarantoolapp is a cli tool so it is better to install it globally to system:

```
$ luarocks install tarantoolapp
```

Or to install most recent version

```
$ luarocks install --server=http://luarocks.org/dev tarantoolapp
```

In order for this to succeed it is required to have both Tarantool and Luarocks repos in `~/.luarocks/config.yaml`:
```
➜ cat ~/.luarocks/config.lua        
rocks_servers = {[[http://rocks.tarantool.org]], [[https://luarocks.org]]}
```

## Bootstrap an application

To create a project template for application with name `myapp` in current directoty:

```
$ tarantoolapp create myapp
```

Full command is:

```
$ tarantoolapp create [-t <template>] [-p <path>]
       [--description <description>] [--version <version>] [-h] <name>
```

### Parameters to `tarantoolapp create`:

* **`<name>`** - Desired project name
* **`<template>`** - template to use. Available templates: (basic, luakit, ckit) (default: basic)
* **`<path>`** - path to directory where to setup project (default is ./{your_project_name})
* **`<description>`** - Project description (default: Tarantool App)
* **`<version>`** - Project version (default: scm-1)

There can be special options defined for a selected template, for example for a `basic` template:

* **`<basic_use_spacer>`** - Use [spacer](https://github.com/igorcoding/tarantool-spacer) or not.

These options are defined in a `templates/<template_name>/config.yaml` file and in command line are prefixed with a template name.


## Install dependencies

```
$ tarantoolapp dep
```

This command installs dependencies, specified in the `meta.yaml` file in current folder (luarocks and Lua 5.1 are required).

Full command is:

```
$ tarantoolapp dep [-m <meta_file>] [-t <tree>]
       [--luarocks-config <luarocks_config>] [-h]
       [--only [<only>] ...]
```

### Parameters to `tarantoolapp dep`:

* **`<meta_file>`** - path to meta.yaml file (default: ./meta.yaml)
* **`<tree>`** - path to directory that will hold the dependencies (default: .rocks)
* **`<luarocks_config>`** - path to luarocks config (default: $HOME/.luarocks/config.lua)
* **`<only>`** - install only these sections (deps, tntdeps or localdeps). Separated with spaces (e.g. `--only deps tntdeps`)


### meta.yaml
`meta.yaml` can have the following sections:
* `name` - package name
* `version` - package version
* `deps` - list of paths to rockspec files or package names (each is installed using `luarocks install` command)
* `tntdeps` - list of paths to rockspec files or package names (each is installed using `tarantoolctl rocks install` command)
* `localdeps` - list of paths to local rockspec files (each is installed using `luarocks make` command). You can specify dependency in either of 2 following formats:
    - `./local/path/to/package/package.rockspec` if `*.rockspec` file is in the package root
    - `./local/path/to/package/rockspecs/package.rockspec:./local/path/to/package` - specify the package root after the colon

## Getting help

```
$ tarantoolapp -h
```

```
$ tarantoolapp create -h
```

```
$ tarantoolapp dep -h
```
