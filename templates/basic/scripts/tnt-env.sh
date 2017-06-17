#! /usr/bin/env bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT=${SCRIPT_DIR}/..

LUA_PATH="${ROOT}/?.lua;\
${ROOT}/?/init.lua;\
${ROOT}/app/?.lua;\
${ROOT}/app/?/init.lua;\
${ROOT}/libs/share/lua/5.1/?.lua;
${ROOT}/libs/share/lua/5.1/?/init.lua;;"

LUA_CPATH="${ROOT}/libs/lib/lua/5.1/?.so;\
${ROOT}/libs/lib/lua/?.so;;"
