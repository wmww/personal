# Not executable because this needs to be sourced

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TRIPLET=$(gcc -dumpmachine)

export PANGO_INSTALL="$DIR/install"
mkdir -p $PANGO_INSTALL

if test -z "$CUSTOM_PANGO_SET"; then
    export   CUSTOM_PANGO_SET=1
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PANGO_INSTALL/usr/local/lib/$TRIPLET/"
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$PANGO_INSTALL/usr/local/lib/$TRIPLET/pkgconfig"
else
    echo "Environment already set up"
fi

echo "Using Pango in $PANGO_INSTALL (v$($PANGO_INSTALL/usr/local/bin/pango-view --version | cut -d' ' -f 3))"
