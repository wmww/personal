#!/bin/bash
set -euox pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cp "$DIR/bat-logger.service" "/etc/systemd/system/"
cp "$DIR/bat-logger.py" "/usr/local/bin/"
systemctl enable --now bat-logger
systemctl status bat-logger
