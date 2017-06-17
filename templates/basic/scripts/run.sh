#! /usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT=${SCRIPT_DIR}/..

. ${SCRIPT_DIR}/tnt-env.sh

TNT_DIR=${ROOT}/tnt_${LISTEN}
mkdir -p ${TNT_DIR}
pushd ${TNT_DIR} > /dev/null
	LUA_PATH=${LUA_PATH} LUA_CPATH=${LUA_CPATH} DEV=1 CONF=${ROOT}/conf.lua tarantool ${ROOT}/init.lua
popd > /dev/null
