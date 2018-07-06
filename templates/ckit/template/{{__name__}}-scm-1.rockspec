-- name of the package to be published
package = '{{__name__}}'

-- version of the package; it's mandatory, but we don't use it in Tarantool;
-- instead, provide below a specific branch in the package's repository at
-- GitHub and set version to some stub value, e.g. 'scm-1'
version = 'scm-1'

-- url and branch of the package's repository at GitHub
source  = {
    url    = 'git://github.com/tarantool/{{__name__}}.git';
    branch = 'master';
}

-- general information about the package;
-- for a Tarantool package, we require three fields (summary, homepage, license)
-- and more package information is always welcome
description = {
    summary  = "C module template for Tarantool";
    detailed = [[
    A ready-to-use C module template.
    Clone and modify it to create new modules.
    ]];
    homepage = 'https://github.com/tarantool/{{__name__}}.git';
    maintainer = "Roman Tsisyk <roman@tarantool.org>";
    license  = 'BSD2';
}

-- Lua version and other packages on which this one depends;
-- Tarantool currently supports strictly Lua 5.1
dependencies = {
    'lua == 5.1';
}

-- filenames to be tested for existence;
-- in TARANTOOL section, specify all C header files needed to build the package
external_dependencies = {
    TARANTOOL = {
        header = 'tarantool/module.h';
    };
}

-- build options and paths for the package;
-- this package distributes modules in C, so the build type = 'cmake';
-- also, specify here all variables required for build:
-- CMAKE_BUILD_TYPE = Tarantool build type (default is RelWithDebInfo)
-- TARANTOOL_INSTALL_LIBDIR = path to all C header files within the package,
-- TARANTOOL_INSTALL_LUADIR = path to all Lua source files within the package
build = {
    type = 'cmake';
    variables = {
        CMAKE_BUILD_TYPE="RelWithDebInfo";
        TARANTOOL_DIR="$(TARANTOOL_DIR)";
        TARANTOOL_INSTALL_LIBDIR="$(LIBDIR)";
        TARANTOOL_INSTALL_LUADIR="$(LUADIR)";
    };
}
-- vim: syntax=lua ts=4 sts=4 sw=4 et
