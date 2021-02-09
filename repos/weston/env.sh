# Not executable because this needs to be sourced
# More info here: https://wayland.freedesktop.org/building.html

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL="$DIR/install"
TRIPLET=$(gcc -dumpmachine)

if test -z $PATH_BEFORE ; then
    PATH_BEFORE="$PATH"
fi

if test -z $LD_LIBRARY_PATH_BEFORE ; then
    LD_LIBRARY_PATH_BEFORE="$LD_LIBRARY_PATH"
fi

export PATH="$PATH_BEFORE:$INSTALL/bin/"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH_BEFORE:$INSTALL/lib/$TRIPLET/"

echo "Using Weston in $INSTALL"
