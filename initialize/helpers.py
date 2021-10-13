from typing import Any, Sequence, Optional
import subprocess
import logging

class Run:
    def __init__(
        self,
        args: Sequence[str],
        dry_run: bool,
        cwd: Optional[str] = None,
        stdin_text: Optional[str] = None,
        passthrough=False
    ):
        self.args = args
        if dry_run:
            print('Would run `' + ' '.join(args) + '`')
            self.stdout = ''
            self.stderr = ''
            self.exit_code = 0
        else:
            logging.info('Running `' + ' '.join(args) + '`')
            io = None if passthrough else subprocess.PIPE
            p = subprocess.Popen(args, cwd=cwd, stdout=io, stderr=io)
            stdin_bytes = stdin_text.encode('utf-8') if stdin_text is not None else None
            stdout, stderr = p.communicate(stdin_bytes)
            self.stdout = stdout.decode('utf-8') if stdout != None else ''
            self.stderr = stderr.decode('utf-8') if stderr != None else ''
            self.exit_code = p.returncode

    def assert_success(self) -> None:
        assert self.exit_code == 0, (
            '`' + ' '.join(self.args) + '` exited with code ' + str(self.exit_code) + ':\n' +
            self.stdout + '\n---\n' + self.stderr
        )

def assert_type(value: Any, expected_type: Any, value_name: str):
    assert isinstance(value, expected_type), (
        str(value_name) + ' is type ' + str(type(value)) + ' instead of ' + str(expected_type)
    )
