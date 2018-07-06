package = 'tarantoolapp'
version = 'scm-1'

source  = {
    url    = 'git://github.com/moonlibs/tarantoolapp';
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
    'datafile',
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
        ['tarantoolapp.util']            = 'tarantoolapp/util.lua'
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
