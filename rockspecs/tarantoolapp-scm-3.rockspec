package = 'tarantoolapp'
version = 'scm-3'

source  = {
    url    = 'gitrec+https://github.com/moonlibs/tarantoolapp';
    branch = 'master';
}

description = {
    summary  = "App starter for Tarantool application server";
    homepage = 'https://github.com/moonlibs/tarantoolapp';
    license  = 'MIT';
    maintainer = "Mons Anderson <mons@cpan.org>, Igor Latkin <igorcoding@gmail.com>";
}

dependencies = {
    'lua >= 5.1',
    'luarocks-fetch-gitrec',
    --'datafile',
    'lua-resty-template ~> 1.9',
}


build = {
    type = 'builtin',
    copy_directories = {'templates'},
    modules = {
        ['tarantoolapp.compat']          = 'tarantoolapp/compat.lua',
        ['tarantoolapp.argparse']        = 'tarantoolapp/argparse.lua',
        ['tarantoolapp.commands']        = 'tarantoolapp/commands.lua',
        ['tarantoolapp.commands.create'] = 'tarantoolapp/commands/create.lua',
        ['tarantoolapp.commands.dep']    = 'tarantoolapp/commands/dep.lua',
        ['tarantoolapp.fileio']          = 'tarantoolapp/fileio.lua',
        ['tarantoolapp.util']            = 'tarantoolapp/util.lua',

        ['datafile']                  = "third_party/datafile/datafile.lua",
        ["datafile.openers.caller"]   = "third_party/datafile/datafile/openers/caller.lua",
        ["datafile.openers.luarocks"] = "third_party/datafile/datafile/openers/luarocks.lua",
        ["datafile.util"]             = "third_party/datafile/datafile/util.lua"
    },
    platforms = {
        unix = {
            modules = {
                ["datafile.openers.xdg"]  = "third_party/datafile/datafile/openers/xdg.lua",
                ["datafile.openers.unix"] = "third_party/datafile/datafile/openers/unix.lua",
            }
        },
        windows = {
            modules = {
                ["datafile.openers.windows"] = "third_party/datafile/datafile/openers/windows.lua",
            }
        },
    },
    install = {
        bin = {
            ['tarantoolapp'] = 'bin/tarantoolapp.lua'
        };
        --conf = {
        --    ['tarantoolapp.conf'] = 'tarantoolapp.conf';
        --};
    };
}
