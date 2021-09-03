#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL="$DIR/install"
cp "$INSTALL/share/dbus-1/services/org.freedesktop.mate.Notifications.service" "/usr/share/dbus-1/services/org.freedesktop.mate.Notifications.service"
