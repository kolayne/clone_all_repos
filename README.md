# Clone All Repos

A tool to clone all repos of a GitHub user.

## Requirements

This repo conatins `bash` scripts that will run on an OS with `curl`, `git` and `jq` installed.

## Running

### Create first snapshot

Basic/minimal example: clones all public repositories of either user or organization USERNAME to the directory:
```bash
# Go to the directory where to clone
cd path/to/root/clone/directory  # Subfolders for users/organizations will be created here

# Run the script
path/to/project/clone_all_repos.sh -u USERNAME
```

All arguments at once:
```bash
../clone_all_repos/clone_all_repos.sh \
        --user USERNAME  `# Clone repos of USERNAME` \
        --no-forks  `# Do not clone repos that are forks` \
        --token <github_access_token>  `# Gives access to private repos/orgs, details below` \
        --include-explicitly-accessible  `# Clone also repos USERNAME has explicit access to` \
        --include-organizations  `# Clone also repos of organizations that USERNAME belongs to` \
        --  `# Everything after this is forwarded to git clone, for example:` \
        --quiet  `# Do not show cloning progress` \
        --depth 1  `# Only get the current state of the repo, not the whole commits history`
```

### Maintain the snapshot

You might want to reuse an existing snapshot and only fetch changes of those.

- To download the new repositories that might have been created since the snapshot creation, just run
  `clone_all_repos.sh` in the root clone directory (the root directory of the snapshot). It will output
  errors for repositories that already exist and download new ones that satisfy the arguments.
- To pull or fetch changes of repositories in a snapshot, run the `update_clones.sh` script! For example:
  ```bash
  /path/to/update_clones.sh pull path/to/root/clone/directory
  ```
  It will pull (or fetch, if you replace "pull" with "fetch") the remote changes of all the repos in the
  snapshot. You may specify more arguments, they will be forwarded to the git pull/fetch command.

## Token

GitHub access token is needed to grant permissions to read private repositories and/or organizations with private
membership. To create a token, go to https://github.com/settings/tokens, create a token, specify permissions
(complete **repo** permission seems to be sufficient (and necessary?) for both), and put the token string to the
command's args
