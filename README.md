# tarantoolapp
App starter for Tarantool application server


## Installation

tarantoolapp is a cli tool so it is better to install it globally to system:

```
$ luarocks install https://raw.githubusercontent.com/moonlibs/tarantoolapp/master/rockspecs/tarantoolapp-scm-1.rockspec
```

## Usage

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
* `TEMPLATE` - Template to use (currently available: `basic`)
* `PATH` - custom path where project will be created. If not specified the project is created in the current working directory under `NAME` folder