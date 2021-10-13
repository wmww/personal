#!/usr/bin/python3

from helpers import assert_type
from collections import OrderedDict
from typing import Optional

class Context:
    def __init__(self, dry_run: bool):
        self.dry_run = dry_run

class JobList:
    def __init__(self) -> None:
        self.jobs: OrderedDict[str, Job] = OrderedDict()
        self.current_config_source: Optional[str] = None

    def add(self, job: 'Job') -> None:
        assert job.name not in self.jobs, (
            'multiple jobs have name ' + job.name + ', from ' +
            str(self.jobs[job.name].config_source) + ' and ' + str(job.config_source)
        )
        self.jobs[job.name] = job

job_list = JobList()

class Job:
    def __init__(self, **kwargs) -> None:
        self.name: str = kwargs.pop('name', self.type_name())
        assert_type(self.name, str, 'job name')
        self.config_source = job_list.current_config_source
        if kwargs:
            assert False, 'job has invalid arg(s): ' + ', '.join(kwargs.keys())
        job_list.add(self)

    def type_name(self) -> str:
        return type(self).__name__

    def run(self, ctx: Context) -> None:
        raise NotImplementedError()
