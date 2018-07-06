<a href="http://tarantool.org">
	<img src="https://avatars2.githubusercontent.com/u/2344919?v=2&s=250" align="right">
</a>
<a href="https://travis-ci.org/tarantool/{{__name__}}">
	<img src="https://travis-ci.org/tarantool/{{__name__}}.png?branch=master" align="right">
</a>

# Lua module template for Tarantool 1.6+

Use this template to create and publish a [Tarantool][] module written in pure
Lua.

**Note:** If you write a Tarantool module in C, see the [ckit][Ckit] branch of
this repository.

## Table of contents
* [Kit content](#kit-content)
* [Prerequisites](#prerequisites)
* [Examples](#examples)
* [See also](#see-also)

## Kit content

  * `./README.md` - this file
  * `./{{__name__}}/init.lua` - the Lua module itself, loaded with `require('{{__name__}}')`
  * `./{{__name__}}-scm-1.rockspec` - a specification for the
    [tarantool/rocks][TarantoolRocks] repository
  * `./test/{{__name__}}.test.lua` - tests for the module
  * `./rpm/` - files to build an RPM package
  * `./debian/` - files to build a DEB package

## Prerequisites

Tarantool 1.6.8+ with header files (`tarantool` and `tarantool-dev` packages)

## Usage

1. Implement your code in `./{{__name__}}/`.

   You will have one or more Lua modules that export their functions for
   API calls.

   As an example, see the Lua module [{{__name__}}/init.lua][LuaModule] from the
   `{{__name__}}` package. Here we have one internal function (`test()`), and we
   export it as `test` for API calls.

   As a result, after we publish the `{{__name__}}` package in step 5, Tarantool
   users will be able to load the package and call the function `test()` with
   `require('{{__name__}}').test(arg)`.

   **Note:** The basics of [creating a Lua module][CreateLuaModule] for
   Tarantool are explained in the Tarantool manual.

2. Add tests to `./test/{{__name__}}.test.lua`:

    ```bash
    prove -v ./test/{{__name__}}.test.lua or ./test/{{__name__}}.test.lua
    ```

3. Update copyright and README files.

4. Push all files except `rpm/`, `debian/` and `{{__name__}}-scm-1.rockspec`.

5. Update and check the rockspec.

   A `.rockspec` file wraps a module into a package. This is what you can
   publish. If you are new to Lua rocks, see general information on rockspec
   [format][RockSpecFormat] and [creation][RockSpecCreation].

   Your rockspec must comply with [these requirements][Requirements]
   and allow to build and install your package locally:

    ```bash
    luarocks install --local mymodule-scm-1.rockspec
    ```

    See an annotated rockspec example in [{{__name__}}-scm-1.rockspec][LuaRockSpec].

8. Push your rockspec and make a pull request to the
   [tarantool/rocks][TarantoolRocks] repository.

   The Tarantool team will review the request and decide on including your
   package in [Tarantool rocks list][TarantoolRocksList] and
   [official Tarantool images for Docker][TarantoolDocker].

9. [Optional] Check DEB packaging and push `debian/` to GitHub.

    ```bash
    dpkg-buildpackage -D -b -us -uc
    ls -l ../*.deb
    ```

10. [Optional] Check RPM packaging and push `rpm/` to GitHub.

    ```bash
    tar cvzf ~/rpmbuild/SOURCES/tarantool-mymodule-1.0.0.tar.gz
    rpmbuild -b rpm/tarantool-mymodule.spec
    ```

Enjoy! Thank you for contributing to Tarantool.

## Examples

 * [Lua module example](http://github.com/tarantool/queue)
 * [One more Lua module example](http://github.com/tarantool/gperftools)

## See also

 * [Tarantool/Lua API Reference][TarantoolLuaReference]
 * [Modulekit for Tarantool modules in C][Ckit]

[Tarantool]: http://github.com/tarantool/tarantool
[Download]: http://tarantool.org/download.html
[Requirements]: http://github.com/tarantool/rocks#contributing
[RockSpecFormat]: http://github.com/keplerproject/luarocks/wiki/Rockspec-format
[RockSpecCreation]: http://github.com/luarocks/luarocks/wiki/Creating-a-rock
[LuaCReference]: http://pgl.yoyo.org/luai/i/_
[TarantoolLuaReference]: http://tarantool.org/doc/reference/index.html
[TarantoolCReference]: http://tarantool.org/doc/reference/capi.html
[TarantoolRocks]: http://github.com/tarantool/rocks
[TarantoolRocksList]: http://tarantool.org/rocks.html
[TarantoolDocker]: http://github.com/tarantool/docker
[Luakit]: http://github.com/tarantool/modulekit/tree/luakit
[Ckit]: http://github.com/tarantool/modulekit/tree/ckit
[LuaModule]: http://github.com/tarantool/modulekit/blob/luakit/luakit/init.lua
[CModule]: http://github.com/tarantool/modulekit/blob/ckit/ckit/lib.c
[LuaCModule]: http://github.com/tarantool/modulekit/blob/ckit/ckit/init.lua
[LuaRockSpec]: http://github.com/tarantool/modulekit/blob/luakit/luakit-scm-1.rockspec
[CRockSpec]: http://github.com/tarantool/modulekit/blob/ckit/ckit-scm-1.rockspec
[CreateLuaModule]: http://tarantool.org/en/doc/book/app_server/creating_app.html#modules-rocks-and-applications
