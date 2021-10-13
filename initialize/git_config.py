from job import Context, Job
from helpers import assert_type, Run
from typing import Optional, Dict
import logging

def current_options() -> Dict[str, str]:
    result = Run(['git', 'config', '--global', '--list'], dry_run=False).assert_success().stdout
    current = {}
    for line in result.splitlines():
        line = line.strip()
        if line:
            key_val = line.split('=', 1)
            if len(key_val) == 2:
                current[key_val[0]] = key_val[1]
    return current

class GitConfig(Job):
    def __init__(self, options: Dict[str, str], **kwargs):
        super().__init__(**kwargs)
        self.options = options

    def run(self, ctx: Context) -> None:
        current = current_options()
        changed = 0
        for k, v in self.options.items():
            if k not in current or current[k] != v:
                Run(['git', 'config', '--global', k, v], dry_run=ctx.dry_run).assert_success()
                changed += 1
        if changed > 0:
            logging.info('set %d git option(s)', changed)
        else:
            logging.info('all git options were already correct')

def job(**kwargs) -> None:
    options: Optional[Dict[str, str]] = kwargs.pop('options');
    assert_type(options, dict, 'options')
    assert isinstance(options, dict), 'options is type ' + str(type(options)) + ' instead of dict'
    for i, (k, v) in enumerate(options.items()):
        assert_type(k, str, 'options key ' + str(i))
        assert_type(v, str, 'options value ' + str(i))
    GitConfig(options, **kwargs)
