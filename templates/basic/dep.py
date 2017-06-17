#! /usr/bin/env python

import argparse
import os

import sys

import subprocess
from os.path import expanduser


class Options:
    def __init__(self,
                 meta_config,
                 meta_path,
                 dev,
                 luarocks_config,
                 luarocks_tree):
        self.meta_config = meta_config
        self.meta_path = meta_path
        self.dev = dev
        self.luarocks_config = luarocks_config
        self.luarocks_tree = luarocks_tree


def ensure_tarantool_rocks_repo(luarocks_config):
    luarocks_config_dir = os.path.dirname(luarocks_config)
    if not os.path.isdir(luarocks_config_dir):
        os.mkdir(luarocks_config_dir)

    if os.path.exists(luarocks_config):
        with open(luarocks_config, 'r') as f:
            f_contents = f.read()
            if 'rocks.tarantool.org' in f_contents:
                return

    with open(luarocks_config, 'a') as f:
        f.write('\nrocks_servers = {[[http://rocks.tarantool.org/]]}\n')


def luarocks_install(dep, local=True, tree=None):
    cmd = ['luarocks', 'install']
    if tree:
        cmd.append("--tree={0}".format(tree))
    elif local:
        cmd.append('--local')
    cmd.append(dep)

    process = subprocess.Popen(cmd)
    exit_code = process.wait()
    
    assert exit_code == 0, "{0} failed".format(cmd)

    print('{0} finished'.format(cmd, exit_code))


def run(opts):
    app_name = opts.meta_config.get('name')
    assert app_name, 'name must be defined'

    # noinspection PyRedeclaration
    def fprint(s):
        print('[{0}] {1}'.format(app_name, s))

    fprint('Installing dependencies...')

    general_deps = opts.meta_config.get('deps', [])
    tnt_deps = opts.meta_config.get('tntdeps', [])

    if not general_deps and not tnt_deps:
        fprint('Nothing to install')

    if tnt_deps:
        ensure_tarantool_rocks_repo(opts.luarocks_config)
        for dep in tnt_deps:
            luarocks_install(dep, local=opts.dev, tree=opts.luarocks_tree)
            fprint('Installed tntdep: {0}'.format(dep))

    if general_deps:
        for dep in general_deps:
            luarocks_install(dep, local=opts.dev, tree=opts.luarocks_tree)
            fprint('Installed dep: {0}'.format(dep))

    return 0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--meta-file', help='meta.json file with tarantool deps', required=True)
    parser.add_argument('--dev', help='pass True if this is dev', type=bool, default=False)
    parser.add_argument('--json', help='use json meta file instead of yaml', type=bool, default=False)
    parser.add_argument('--luarocks-config',
                        help='path to luarocks config file',
                        type=str,
                        default=expanduser('~/.luarocks/config.lua'))
    parser.add_argument('--luarocks-tree',
                        help='path to luarocks installation tree',
                        type=str,
                        default=None)
    args = parser.parse_args()

    meta_file = os.path.abspath(args.meta_file)
    with open(meta_file, 'r') as f:
        if args.json:
            import json
            meta_config = json.load(f, encoding='utf-8')
        else:
            import yaml
            meta_config = yaml.load(f)

    opts = Options(meta_config=meta_config,
                   meta_path=os.path.dirname(meta_file),
                   dev=args.dev,
                   luarocks_config=args.luarocks_config,
                   luarocks_tree=args.luarocks_tree)
    return run(opts)

if __name__ == "__main__":
    sys.exit(main())
