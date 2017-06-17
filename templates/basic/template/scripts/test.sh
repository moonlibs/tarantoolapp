#! /usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT=${SCRIPT_DIR}/..

. ${SCRIPT_DIR}/tnt-env.sh
TESTS=${ROOT}/t/*.lua

for t in $TESTS
do
	echo "Processing `basename $t`..."
	LUA_PATH=${LUA_PATH} LUA_CPATH=${LUA_CPATH} tarantool $t
done
