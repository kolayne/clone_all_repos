# Clone All Repos

A tool to create and maintain snapshots of all GitHub repositories related to a user.

It is useful in cases when you want to have an additional backup of data you keep on GitHub.

## Requirements

This repo conatins `bash` scripts that will run on a machine with `curl`, `git`, and `jq` installed.

## Running

### Create first snapshot

Basic/minimal example: clones all public repositories of either a user or an organization \<USERNAME\>
to the current directory:
```bash
./clone_all_repos.sh -u USERNAME -o .
```

All arguments at once:
```bash
./clone_all_repos.sh \
        --user USERNAME  `# Clone repos of USERNAME` \
        --output-directory path/to/snapshot/root/directory  `# Where to store the snapshot` \
        --no-forks  `# Do not clone repos that are forks` \
        --token GITHUB_ACCESS_TOKEN  `# Gives access to private repos/orgs, see details in README` \
        --include-explicitly-accessible  `# Clone also repos USERNAME has explicit access to` \
        --include-organizations  `# Clone also repos of organizations that USERNAME belongs to` \
        --https  `# Use HTTPS instead of SSH when cloning. For private repos the token will be stored in the cloning URL!!` \
        --  `# Everything after the double dash is forwarded to git clone, for example:` \
        --quiet  `# Do not show cloning progress` \
        --depth 1  `# Only get the current state of the repo, not the whole commits history`
```

Note: arguments `--include-explicitly-accessible` and `--include-organizations` will only work if `USERNAME`
is a GitHub _user_, not an organization.

### Maintain the snapshot

You might want to reuse an existing snapshot and only fetch new changes.

1.  Since you created the snapshots, **new repositories** that match your conditions may have been created.
    To add them to your snapshot, run `clone_all_repos.sh` again with desired arguments. It will output errors
    for repositores that already exist and download new ones that match the query specified in the arguments.

2.  To pull or fetch changes of repositories **already in the snapshot**, run `update_clones.sh`. For example:
    ```bash
    ./update_clones.sh pull path/to/snapshot/root/directory
    ```
    It will pull (or fetch, if you replace "pull" with "fetch") the remote changes of all the repos in the
    snapshot. If there is more than 2 arguments specified to `update_clones.sh`, all the remaining ones are
    forwarded to the git pull/fetch command.

## Token

GitHub access token is needed to grant permissions to read private repositories and/or organizations with private
membership. To create a token, go to https://github.com/settings/tokens, create a token, specify permissions
(complete **repo** permission seems to be sufficient (and necessary?) for both), and put the token string to the
command's args.

If you _don't specify a token_, you can still clone _public_ repositories _owned_ by the given user and the
organizations that the user is a _public_ member of. Conversely, if a _token with insufficient permissions_ is
specified (e.g. attempt to clone public repos with a token that has no **repo:read** permission), this will
lead to an error.
