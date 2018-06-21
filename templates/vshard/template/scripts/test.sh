#! /usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT=${SCRIPT_DIR}/..

TARANTOOL=tarantool

LUA_PATH="${ROOT}/?.lua;\
${ROOT}/?/init.lua;\
${ROOT}/app/?.lua;\
${ROOT}/app/?/init.lua;\
${ROOT}/.rocks/share/lua/5.1/?.lua;
${ROOT}/.rocks/share/lua/5.1/?/init.lua;;"

LUA_CPATH="${ROOT}/.rocks/lib/lua/5.1/?.so;\
${ROOT}/.rocks/lib/lua/?.so;\
${ROOT}/.rocks/lib64/lua/5.1/?.so;;"

for t in ${ROOT}/t/*.lua; do
    echo "Running `basename $t`..."
    LUA_PATH=${LUA_PATH} LUA_CPATH=${LUA_CPATH} ${TARANTOOL} $t
done
