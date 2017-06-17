package = 'tarantoolapp'
version = 'scm-1'

source  = {
    url    = 'https://github.com/moonlibs/tarantoolapp';
    branch = 'master';
}

description = {
    summary  = "App starter for Tarantool application server";
    homepage = 'https://github.com/moonlibs/tarantoolapp';
    license  = 'MIT';
    maintainer = "Mons Anderson <mons@cpan.org>, Igor Latkin <igorcoding@gmail.com>";
}

dependencies = {
    'lua >= 5.1';
}


build = {
    type = 'builtin';
    copy_directories = {'templates'};
    modules = {
        ['tarantoolapp.cli']    = 'tarantoolapp/cli.lua';
        ['tarantoolapp.create'] = 'tarantoolapp/create.lua';
        ['tarantoolapp.fileio'] = 'tarantoolapp/fileio.lua';
        ['tarantoolapp.util'] = 'tarantoolapp/util.lua';
    };
    install = {
        bin = {
            ['tarantoolapp'] = 'bin/tarantoolapp.lua';
        };
        --conf = {
        --    ['tarantoolapp.conf'] = 'tarantoolapp.conf';
        --};
    };
}
