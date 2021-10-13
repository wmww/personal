#!/usr/bin/python3

from job import Context, Job, JobList, job_list
from helpers import assert_type
from typing import Sequence, List, Tuple, Callable, Any
import importlib.util
import logging

# TODO:
# - persistant logging

def load_config(path: str):
    job_list.current_config_source = path
    spec = importlib.util.spec_from_file_location('config_mod', path)
    assert spec is not None, path + ' failed to load as python module'
    mod = importlib.util.module_from_spec(spec)
    assert isinstance(spec.loader, importlib.abc.Loader)
    spec.loader.exec_module(mod)
    job_list.current_config_source = None

def load_config_list(paths: Sequence[str]) -> bool:
    success = True
    for path in paths:
        logging.info('loading config script %s', path)
        try:
            load_config(path)
        except (AssertionError, RuntimeError, FileNotFoundError) as e:
            success = False
            logging.error('%s: %s', path, e)
    return success

def run_job(job: Job, ctx: Context):
    logging.info('running job %s of type %s', job.name, job.type_name())
    job.run(ctx)

def build_ctx(args) -> Context:
    return Context(dry_run=args.dry_run)

def run_all(jobs: JobList, args):
    ctx = build_ctx(args)
    for _, job in jobs.jobs.items():
        run_job(job, ctx)

def run_some(jobs: JobList, args):
    ctx = build_ctx(args)
    to_run: List[Job] = []
    for name in args.run:
        assert_type(name, str, 'job name')
        assert name in jobs.jobs, name + ' is not a known job name'
        to_run.append(jobs.jobs[name])
    for job in to_run:
        run_job(job, ctx)

def list_jobs(jobs: JobList, args):
    for name, job in jobs.jobs.items():
        print(' - ' + name + ' (' + job.type_name() + ')')

def main() -> None:
    import argparse
    parser = argparse.ArgumentParser(description='Idempotently initialize a system')
    parser.add_argument('-c', '--config', required=True, nargs='+', help=
        'list of configuration scripts to load. ' +
        'May include relative paths, absolute paths and globs. ' +
        'NOTE: config scripts may execute arbitrary code. Only load trusted scripts.'
    )
    parser.add_argument('-r', '--run', nargs='+', help='list of jobs to run')
    parser.add_argument('-a', '--run-all', action='store_true', help='run all jobs in loaded config scripts')
    parser.add_argument('-l', '--list', action='store_true', help='list jobs in loaded config scripts')
    parser.add_argument('-d', '--dry-run', action='store_true', help='show actions that would be performed without doing anything')
    parser.add_argument('-v', '--verbose', action='store_true', help='verbose output')
    # parser.add_argument('--no-color', action='store_true', help='disable colored output')

    args = parser.parse_args()

    log_level = logging.DEBUG if args.verbose else logging.WARNING
    logging.basicConfig(level=log_level)

    actions: List[Tuple[str, Callable[[JobList, Any], None]]] = []
    if args.run:
        actions.append(('run', run_some))
    if args.run_all:
        actions.append(('run all', run_all))
    if args.list:
        actions.append(('list', list_jobs))
    assert len(actions) > 0, 'no action specified'
    assert len(actions) <= 1, 'multiple actions specified: ' + ', '.join([name for name, fn in actions])
    action = actions[0][1]

    assert load_config_list(args.config), 'loading config scripts experienced error(s)'
    action(job_list, args)

if __name__ == '__main__':
    try:
        main()
    except AssertionError as e:
        logging.error(e)
        exit(1)
