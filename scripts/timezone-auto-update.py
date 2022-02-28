#!/bin/python3

# More extensive version:
#   https://github.com/cdown/tzupdate
# Less extensive version:
#   sudo timedatectl set-timezone "$(curl http://worldtimeapi.org/api/ip/ | grep -Po '(?<="timezone":")[^"]*')"

import json
import requests
import subprocess

def main() -> None:
    print('looking up timezone...')
    response = requests.get('http://worldtimeapi.org/api/ip/')
    body = json.loads(response.content)
    zone = body.get('timezone')
    print('setting timezone to', zone)
    assert zone is not None, 'no timezone: ' + str(body)
    subprocess.run('sudo timedatectl set-timezone'.split() + [zone]).check_returncode()
    print('done')

if __name__ == '__main__':
    main()
