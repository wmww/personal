from job import Context, Job
from helpers import assert_type, Run
from typing import Optional, Dict

class GitConfig(Job):
    def __init__(self, options: Dict[str, str], **kwargs):
        super().__init__(**kwargs)
        self.options = options

    def run(self, ctx: Context) -> None:
        # Use git config --global --list to determine and log which options are changing
        for k, v in self.options.items():
            Run(['git', 'config', '--global', k, v], dry_run=ctx.dry_run).assert_success()

def job(**kwargs) -> None:
    options: Optional[Dict[str, str]] = kwargs.pop('options');
    assert_type(options, dict, 'options')
    assert isinstance(options, dict), 'options is type ' + str(type(options)) + ' instead of dict'
    for i, (k, v) in enumerate(options.items()):
        assert_type(k, str, 'options key ' + str(i))
        assert_type(v, str, 'options value ' + str(i))
    GitConfig(options, **kwargs)
