# Not executable because this needs to be sourced

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL="$DIR/install"
TRIPLET=$(gcc -dumpmachine)

if test -z $PATH_PRE_CUSTOM_GTK ; then
    PATH_PRE_CUSTOM_GTK="$PATH"
fi

if test -z $LD_LIBRARY_PATH_PRE_CUSTOM_GTK ; then
    LD_LIBRARY_PATH_PRE_CUSTOM_GTK="$LD_LIBRARY_PATH"
fi

export PATH="$PATH_PRE_CUSTOM_GTK:$INSTALL/usr/local/bin/"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH_PRE_CUSTOM_GTK:$INSTALL/usr/local/lib/:$INSTALL/usr/local/lib/$TRIPLET/"
export DESTDIR="$INSTALL"

mkdir -p "$INSTALL"

echo "Using GTK in $INSTALL (v$(gtk-launch --version))"
