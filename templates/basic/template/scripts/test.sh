#! /usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

TARANTOOL=tarantool

LUA_PATH="\
${ROOT}/.rocks/share/lua/5.1/?.lua;\
${ROOT}/.rocks/share/lua/5.1/?/init.lua;\
${ROOT}/.rocks/share/tarantool/?.lua;\
${ROOT}/.rocks/share/tarantool/?/init.lua;\
${ROOT}/?.lua;\
${ROOT}/?/init.lua;\
${ROOT}/app/?.lua;\
${ROOT}/app/?/init.lua;\
;"

SOEXT="$(${TARANTOOL} <<< 'print(jit.os == "OSX" and "dylib" or "so")')"

LUA_CPATH="\
${ROOT}/.rocks/lib/lua/5.1/?.${SOEXT};\
${ROOT}/.rocks/lib/lua/?.${SOEXT};\
${ROOT}/.rocks/lib/tarantool/?.${SOEXT};\
${ROOT}/.rocks/lib64/lua/5.1/?.${SOEXT};\
${ROOT}/.rocks/lib64/tarantool/?.${SOEXT};\
;"

for t in ${ROOT}/t/*.lua; do
    echo "Running `basename $t`..."
    LUA_PATH=${LUA_PATH} LUA_CPATH=${LUA_CPATH} ${TARANTOOL} $t
done
