#!/bin/bash

CLONE_ROOT_DIR="."
GH_USERNAME=""
GIT_ARGS=""


usage() {
	echo No help message yet...
	exit 0
}

die() {
	echo "$1" >&2
	exit 1
}


parse_args() {
	while [ -n "$1" ]; do
		case "$1" in
			-h | --help) usage ;;
			-u | --user) shift; GH_USERNAME="$1" ;;
			--) shift; GIT_ARGS=$@; break ;;  # The rest is additional arguments to `git clone`
			*) die Unknown argument "$1" ;;
		esac

		shift
	done

	if [[ -z "$GH_USERNAME" ]]; then
		die "GitHub username must be specified (with --user)"
	fi
}


main() {
	parse_args "$@"

	cd $CLONE_ROOT_DIR || die "Clone root directory does not exist"
	mkdir -p "$GH_USERNAME" && cd "$GH_USERNAME" || die "Failed to create directory for the username"
	CLONE_URLS=$(curl "https://api.github.com/users/$GH_USERNAME/repos" | jq  -er '.[].ssh_url') || \
		die "Couldn't retrieve the repositories list. Is the username correct?"

	for repo_clone_url in $CLONE_URLS; do
		git clone $GIT_ARGS "$repo_clone_url" || \
			echo "Failed to clone repo $repo_clone_url. Trying to continue..." >&2
	done
}


main "$@"
