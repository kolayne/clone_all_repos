# Clone All Repos

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/f0e3a770a8f34710bbf0a8ea5028d1e2)](https://app.codacy.com/gh/kolayne/clone_all_repos?utm_source=github.com&utm_medium=referral&utm_content=kolayne/clone_all_repos&utm_campaign=Badge_Grade_Settings)

A tool to create and maintain snapshots of all GitHub repositories, related to a user.

It is useful in cases when you want to have an additional backup of the data you have in GitHub, for example,
in case your country's government has spontaneously decided to unleash a war against Ukraine and, thanks to
that, all the citizens are now under the risk of being banned by various foreign services.

By the way, I take this opportunity to express my position: #NoToWar / #НетВойне

## Requirements

This repo conatins `bash` scripts that will run on a machine with `curl`, `git` and `jq` installed.

## Running

### Create first snapshot

Basic/minimal example: clones all public repositories of either user or organization \<USERNAME\> to the
current directory:
```bash
path/to/project/clone_all_repos.sh -u USERNAME -o .
```

All arguments at once:
```bash
../clone_all_repos/clone_all_repos.sh \
        --user USERNAME  `# Clone repos of USERNAME` \
        --output-directory path/to/snapshot/root/directory  `# Where to store the snapshot` \
        --no-forks  `# Do not clone repos that are forks` \
        --token GITHUB_ACCESS_TOKEN  `# Gives access to private repos/orgs, details below` \
        --include-explicitly-accessible  `# Clone also repos USERNAME has explicit access to` \
        --include-organizations  `# Clone also repos of organizations that USERNAME belongs to` \
        --https  `# Use HTTPS instead of SSH when cloning. For private repos token will be used` \
        --  `# Everything after this is forwarded to git clone, for example:` \
        --quiet  `# Do not show cloning progress` \
        --depth 1  `# Only get the current state of the repo, not the whole commits history`
```

Note: arguments `--include-explicitly-accessible` and `--include-organizations` will only work if `USERNAME`
is a login of a GitHub _user_, not an organization

### Maintain the snapshot

You might want to reuse an existing snapshot and only fetch new changes.

-   To download the **new repositories** that might have been created since the snapshot creation, just run
    `clone_all_repos.sh` in the snapshot root directory. It will output errors for repositories that already
    exist and download new ones that satisfy the query given in the arguments.

-   To pull or fetch changes of **existing repositories** in a snapshot, run the `update_clones.sh` script!
    For example:
    ```bash
    /path/to/update_clones.sh pull path/to/snapshot/root/directory
    ```
    It will pull (or fetch, if you replace "pull" with "fetch") the remote changes of all the repos in the
    snapshot. If you run `update_clones.sh` with more than 2 arguments, all the rest is forwarded to the
    git clone/fetch command.

## Token

GitHub access token is needed to grant permissions to read private repositories and/or organizations with private
membership. To create a token, go to https://github.com/settings/tokens, create a token, specify permissions
(complete **repo** permission seems to be sufficient (and necessary?) for both), and put the token string to the
command's args.

If you _don't specify a token_, you can still clone _public_ repositories _owned_ by the given user and the
organizations that the user is a _public_ member of. Conversely, if a _token with insufficient permissions_ is
specified (e.g. attempt to clone public repos with a token that has no **repo:read** permission), this will
lead to an error.
