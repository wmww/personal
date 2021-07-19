#!/bin/bash
set -eo pipefail

DIR="$(realpath "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )")"
PCH=$(find "$DIR" -name '*.pch' -o -name '*.gch')
if test -z "$PCH"; then
    echo "No files to remove"
else
    echo "Removing $PCH"
    rm $PCH
fi

