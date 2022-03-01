#!/bin/bash

GH_USERNAME=""
GH_TOKEN=""

CLONE_ROOT_DIR="."
CLONE_FORKS=true

GIT_ARGS=""


usage() {
	echo -e "Usage: $0 <OPTIONS>... [-- <GIT_CLONE_ADDITIONAL_OPTIONS>...]"

	echo -e "\nRequired options:"
	echo -e "\t-u | --user <USERNAME> - GitHub username of the user to clone repos for IN LOWERCASE"

	echo -e "\nOther options:"
	echo -e "\t--no-forks - Do not clone repos that are forks"
	echo -e "\t-t | --token - GitHub personal access token FOR THE USER <USERNAME>. " -n
	echo -e "Given the correct permissions, the token will give access to private repos/organizations"
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
			-u | --user)
				shift
				GH_USERNAME="$1"
				[[ "${1:0:1}" = "-" ]] && die "Invalid username $1 (can't start with a hyphen)"
				;;

			--no-forks) CLONE_FORKS=false ;;

			-t | --token)
				shift
				GH_TOKEN="$1"
				[[ "${1:0:1}" = "-" ]] && die "Invalid token $1 (can't start with a hyphen)"
				;;

			-h | --help) usage ;;

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
	mkdir -p "$GH_USERNAME" && pushd "$GH_USERNAME" || die "Failed to create directory for the username"

	JQ_FILTER=".[]"
	if [[ "$CLONE_FORKS" = false ]]; then
		JQ_FILTER="$JQ_FILTER | select(.fork == false)"
	fi

	if [[ -z "$GH_TOKEN" ]]; then
		WHAT_TO_CURL="https://api.github.com/users/$GH_USERNAME/repos"
	else
		WHAT_TO_CURL="-u $GH_USERNAME:$GH_TOKEN https://api.github.com/user/repos"
		JQ_FILTER="$JQ_FILTER | select(.owner.login == \"$GH_USERNAME\")"
	fi

	JQ_FILTER="$JQ_FILTER | .ssh_url"

	CLONE_URLS=$(curl $WHAT_TO_CURL | jq  -er "$JQ_FILTER") || \
		die "Couldn't retrieve the repositories list. Are the username/token correct?"

	for repo_clone_url in $CLONE_URLS; do
		git clone $GIT_ARGS "$repo_clone_url" || \
			echo "FAILED TO CLONE repo $repo_clone_url. Trying to continue..." >&2
	done
}


main "$@"
