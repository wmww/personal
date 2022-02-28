#!/bin/python3

import subprocess
import re
import logging
from typing import Optional

logging.basicConfig(level=logging.INFO)

def get_distro() -> str:
    result = subprocess.run('lsb_release -a'.split(), encoding='utf-8', capture_output=True)
    result.check_returncode()
    distro = re.findall(r'^Distributor ID:\s*(.+)$', result.stdout, flags=re.MULTILINE)
    assert len(distro) == 1, 'Found ' + str(len(distro)) + ' distro lines'
    return distro[0]

def set_timezone_ubuntu() -> None:
    cmd = 'sudo dpkg-reconfigure tzdata'
    logging.info('running `%s`', cmd)
    subprocess.run(cmd.split()).check_returncode()
    logging.info('success!')

def get_timezones_arch() -> list[str]:
    result = subprocess.run('timedatectl list-timezones'.split(), encoding='utf-8', capture_output=True)
    result.check_returncode()
    return result.stdout.splitlines()

class Zone:
    def __init__(self, name: Optional[str]):
        self.name = name
        self.subzones: dict[str, 'Zone'] = {}

    def consolidate(self) -> None:
        main: dict[str, 'Zone'] = {}
        other: dict[str, 'Zone'] = {}
        for k, v in self.subzones.items():
            if len(v.subzones) > 0:
                main[k] = v
            else:
                other[k] = v
        if len(main):
            main['Other'] = Zone(None)
            main['Other'].subzones = other
            self.subzones = main
        else:
            self.subzones = other
        for k, v in self.subzones.items():
            v.consolidate()

    def join_to(self, prefix: str) -> str:
        if self.name is not None:
            return prefix + '/' + self.name
        else:
            return prefix

def parse_zones(zone_str_list: list[str]) -> Zone:
    result = Zone(None)
    for zone_str in zone_str_list:
        current = result
        for part in zone_str.split('/'):
            if part in current.subzones:
                current = current.subzones[part]
            else:
                current.subzones[part] = Zone(part)
                current = current.subzones[part]
    return result

def user_get_zone(zone: Zone) -> str:
    result = ''
    while len(zone.subzones):
        pairs = list(zone.subzones.items())
        for i, (display, zone) in enumerate(pairs):
            text = str(i + 1) + '. ' + display
            if len(zone.subzones):
                text += ' (' + str(len(zone.subzones)) + ')'
            print(text)
        while True:
            prompt = 'Enter ' + (result + ' sub' if result else '') + 'zone: '
            text = input(prompt)
            try:
                num = int(text)
                if num > 0 and num <= len(pairs):
                    break
                logging.error('%d out of range', num)
            except ValueError:
                logging.error('%s is not a number', text)
        name = pairs[num - 1][1].name
        if name is not None:
            if result:
                result += '/'
            result += name
        zone = pairs[num - 1][1]
    return result

# NOTE: this also seems to work on modern Ubuntu
def set_timezone_arch() -> None:
    zone_str_list = get_timezones_arch()
    logging.info('detected %d timezones', len(zone_str_list))
    zone = parse_zones(zone_str_list)
    zone.consolidate()
    chosen = user_get_zone(zone)
    print('chosen zone: ' + chosen)
    subprocess.run('sudo timedatectl set-timezone'.split() + [chosen]).check_returncode()
    logging.info('timezone set to %s, may need to log out before it takes effect everywhere', chosen)

def main() -> None:
    distro = get_distro()
    logging.info('distro detected as %s', distro)
    if distro == 'Ubuntu':
        set_timezone_ubuntu()
    elif distro == 'Arch':
        set_timezone_arch()
    else:
        assert False, 'Script does not yet support ' + distro

if __name__ == '__main__':
    main()

'''
set -euo pipefail

DISTRO=$(lsb_release -a | grep -Po '(?<=Distributor ID:\t).*$')
if [ -z $DISTRO ]; then
    echo "Could not detect distro"
    exit 1
fi
case "$DISTRO" in
"Arch")
    # Can be done manually with ln -sf /usr/share/zoneinfo/Zone/SubZone /etc/localtime
    sudo tzselect
    ;;
"Ubuntu")
    sudo dpkg-reconfigure tzdata
    ;;
*)
    echo "Script does not yet support $DISTRO"
    exit 1
    ;;
esac
'''
