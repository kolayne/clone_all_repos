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
        --fork-add-parent-remote `# If cloning forks, add the 'upstream' git remote for the parent repo. It is not fetched automatically!` \
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

2.  To pull or fetch changes of repositories **already in the snapshot**, use `foreach.sh`. For example:
    ```bash
    ./foreach.sh path/to/snapshot/root/directory pull
    ```
    It will pull the remote changes of all the repos in the snapshot. Instead of `pull` you can also specify
    `fetch`, `pull --all`/`fetch --all` (recommended for forks cloned with `-p`/`--fork-add-parent-remote`),
    or anything else. If there is more than 2 arguments given to `foreach.sh`, all the remaining ones
    are forwarded to the git command.

## Token

GitHub access token is needed to grant permissions to read private repositories and/or organizations with private
membership. To create a token, go to https://github.com/settings/tokens, create a token, specify permissions
(complete **repo** permission seems to be sufficient (and necessary?) for both), and put the token string to the
command's args.

If you _don't specify a token_, you can still clone _public_ repositories _owned_ by the given user and the
organizations that the user is a _public_ member of. Conversely, if a _token with insufficient permissions_ is
specified (e.g. attempt to clone public repos with a token that has no **repo:read** permission), this will
lead to an error.

<hr>

I regret the way I designed this tool... The source code is unmaintainable...
