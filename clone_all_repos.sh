#!/bin/bash

CLONE_ROOT_DIR="."
GH_USERNAME=""
CLONE_FORKS=true

GIT_ARGS=""


usage() {
	echo -e "Usage: $0 <OPTIONS>... [-- <GIT_CLONE_ADDITIONAL_OPTIONS>...]"

	echo -e "\nRequired options:"
	echo -e "\t-u | --user <USERNAME> - GitHub username of the user to clone repos for"

	echo -e "\nOther options:"
	echo -e "\t--no-forks - Do not clone repos that are forks"
	echo -e "\t-h | --help - Display this message"

	echo -e "\nWhen cloning, the following command will be invoked: \`git clone <GIT_CLONE_ADDITIONAL_OPTIONS> <REPO_CLONE_URL>\`"

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
			--no-forks) CLONE_FORKS=false ;;
			--) shift; GIT_ARGS=$@; break ;;  # The rest is additional arguments to `git clone`
			*) die "Unknown argument $1" ;;
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

	JQ_FILTER=".[]"
	if [[ "$CLONE_FORKS" = false ]]; then
		JQ_FILTER="$JQ_FILTER | select(.fork == false)"
	fi
	JQ_FILTER="$JQ_FILTER | .ssh_url"

	CLONE_URLS=$(curl "https://api.github.com/users/$GH_USERNAME/repos" | jq  -er "$JQ_FILTER") || \
		die "Couldn't retrieve the repositories list. Is the username correct?"

	for repo_clone_url in $CLONE_URLS; do
		git clone $GIT_ARGS "$repo_clone_url" || \
			echo "FAILED TO CLONE repo $repo_clone_url. Trying to continue..." >&2
	done
}


main "$@"
