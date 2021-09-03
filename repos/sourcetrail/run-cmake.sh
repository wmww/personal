#!/bin/bash
set -eo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if test $(dirname $PWD) != $DIR; then
    echo "You are not in a subdir of $DIR, this is probably a mistake"
    exit 1
fi

# Generate compile_commands.json so we can index ourself
export CMAKE_EXPORT_COMPILE_COMMANDS=1

# If things fail, see readme for setting up depends

cmake "$DIR" -DCMAKE_BUILD_TYPE=Release -DBUILD_CXX_LANGUAGE_PACKAGE=ON -DBUILD_PYTHON_LANGUAGE_PACKAGE=ON -DBUILD_JAVA_LANGUAGE_PACKAGE=OFF $@

