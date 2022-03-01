# Clone All Repos

A tool to clone all repos of a GitHub user.

## Requirements

This repo conatins `bash` scripts that will run on an OS with `curl`, `git` and `jq` installed.

## Running

Basic example:
```bash
# Go to the directory where to clone
cd path/where/to/clone/repos

# Run the script
path/to/clone_all_repos/clone_all_repos.sh --user USERNAME
```

You can also specify additional arguments to `git clone`:
```bash
# To hide progress of the cloning process
../clone_all_repos/clone_all_repos.sh --user USERNAME -- --quiet
```
