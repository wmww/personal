#!/bin/python3
import subprocess
import os
import json
import time
from typing import Any

upower_command = 'upower -i /org/freedesktop/UPower/devices/battery_BAT0'
log_path = os.path.expanduser('/var/log/bat-logger.log')
interval_secs = 10 * 60

def show_error_notification(message: str) -> None:
    title = 'Error in ' + __file__
    icon = 'dialog-warning'
    timeout_secs = 30.0
    timeout_ms = int(timeout_secs * 1000)
    try:
        subprocess.run(
            ['notify-send', '--icon', icon, '--expire-time', str(timeout_ms), title, message],
            check=True)
    except:
        try:
            subprocess.run(
                ['zenity', '--error', '--text=' + title + '\n\n' + message + '\n\n' + '(also FYI notify-send didn\'t work)'],
                check=True)
        except:
            # We do our own imports here so this function can be easily copy-pasted
            import os
            from datetime import datetime
            error_path = os.path.join(os.path.expanduser('~'), 'ERROR_README.txt')
            with open(error_path, 'a') as f:
                f.write(str(datetime.now()) + '\n')
                f.write(title + '\n')
                f.write(message + '\n')
                f.write('(also FYI notify-send and zenity didn\'t work)' + '\n')
                f.write('\n')

def read_upower() -> str:
    result = subprocess.run(
        upower_command.split(),
        check=True, capture_output=True, encoding='utf-8')
    return result.stdout

def parse_upower(raw: str) -> dict[str, str]:
    data: dict[str, str] = {}
    for line in raw.splitlines():
        parts = line.split(':', 1)
        if len(parts) == 2:
            key = parts[0].strip()
            assert key not in data, 'duplicate upower key: ' + key
            data[key] = parts[1].strip()
    return data

def expect_value(data: dict[str, Any], key: str, expected: str) -> None:
    value = data.get(key)
    if value != expected:
        show_error_notification(
            'UPower ' + key +
            ' expected to be ' + expected +
            ', but is actually ' + str(value))
    else:
        del data[key]

def remove_crift(data: dict[str, Any]) -> None:
    expect_value(data, 'power supply', 'yes')
    expect_value(data, 'has history', 'yes')
    expect_value(data, 'has statistics', 'yes')
    expect_value(data, 'present', 'yes')
    expect_value(data, 'rechargeable', 'yes')
    expect_value(data, 'warning-level', 'none')
    data.pop('native-path', None)
    data.pop('vendor', None)
    data.pop('model', None)
    data.pop('serial', None)
    data.pop('updated', None)
    data.pop('icon-name', None)
    data.pop('History (charge)', None)
    data.pop('History (rate)', None)

def parse_values(data: dict[str, Any]) -> None:
    keys = list(data.keys())
    for key in keys:
        value = data[key]
        if value == 'yes':
            data[key] = True
        elif value == 'no':
            data[key] = False
        elif isinstance(value, str) and value and value[0].isdigit():
            i = len(value) - 1
            while not value[i].isdigit():
                i -= 1
            i += 1
            num_str = value[:i].strip()
            if '.' in num_str:
                num = float(num_str)
            else:
                num = int(num_str)
            unit = value[i:].strip()
            if unit:
                del data[key]
                key += ' (' + unit + ')'
            data[key] = num

def write_to_log(data: dict[str, Any]) -> None:
    first_entry = not os.path.exists(log_path)
    with open(log_path, 'a') as f:
        if first_entry:
            data['full_upower_output'] = read_upower()
            f.write('[\n')
        f.write(json.dumps(data))
        f.write(',\n')

def main():
    raw = read_upower()
    data = parse_upower(raw)
    remove_crift(data)
    parse_values(data)
    data['timestamp'] = str(time.time())
    write_to_log(data)

if __name__ == '__main__':
    try:
        while True:
            main()
            time.sleep(interval_secs)
    except Exception as e:
        show_error_notification(str(e))
