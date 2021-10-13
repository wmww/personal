import git_config

git_config.job(name='git', options={
    'user.email': 'wm@wmww.sh',
    'user.name': 'William Wold',
    'core.editor': 'vim',
    'merge.conflictstyle': 'diff3',
    'init.defaultbranch': 'master',
    'pull.rebase': 'true',
})
