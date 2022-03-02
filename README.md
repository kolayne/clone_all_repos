# Clone All Repos

A tool to clone all repos of a GitHub user.

## Requirements

This repo conatins `bash` scripts that will run on an OS with `curl`, `git` and `jq` installed.

## Running

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

## Token

GitHub access token is needed to grant permissions to read private repositories and/or organizations with private
membership. To create a token, go to https://github.com/settings/tokens, create a token, specify permissions
(complete **repo** permission seems to be sufficient (and necessary?) for both), and put the token string to the
command's args
