# Initialization Script

Given a configuration, initializes a system. Configuration comes in the form of one or more python scripts which set up jobs.

## Generic parameters
These are applicable to all jobs
- `name: str`: the name of the job. Must be unique across all loaded config scripts. Defaults to the name of the job type.

## Job Types
To set up a job:
```python3
import job_type
job_type.job(...)
```

### git_config
Sets up git config options. Parameters:
- `options: Dict[str, str]`: key-value pairs of git config options. For example `'core.editor': 'vim'`.
