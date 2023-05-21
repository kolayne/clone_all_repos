#!/bin/bash

source "$(dirname "$0")/_common"

GIT_CMD=""
SNAPSHOT_ROOT_DIR=""
ADDITIONAL_GIT_ARGS=""


usage() {
	echo -e "Usage: $0 [--help] pull|fetch <SNAPSHOT_ROOT_DIRECTORY> [<ADDITIONAL_GIT_ARGS>...]"

	echo -ne "\nThis will either pull or fetch all the repositories located in "
	echo -e "<SNAPSHOT_ROOT_DIRECTORY> (not recursively, only the first-level subdirectories)"

	exit 0
}


parse_args() {
	[[ "$1" = "--help" || "$2" = "--help" ]] && usage

	if [[ "$1" = "fetch" || "$1" = "pull" ]]; then
		GIT_CMD="$1"
	else
		die "The first argument must be either pull or fetch"
	fi

	[[ -z "$2" ]] && \
		die "You have to specify the snapshot root directory as the second argument"
	[[ "${2:0:1}" = "-" ]] && \
		die "The directory name $2 starts with a hyphen. Did you really mean that? If so, \
make it ./$2"

	SNAPSHOT_ROOT_DIR="$2"

	shift 2

	ADDITIONAL_GIT_ARGS="$@"
}


main() {
	parse_args "$@"
	cd "$SNAPSHOT_ROOT_DIR" || die "Failed to enter the directory $SNAPSHOT_ROOT_DIR"

	for subdir in */*/; do
		pushd "$subdir" && git "$GIT_CMD" $ADDITIONAL_GIT_ARGS || \
			echo "FAILED TO $GIT_CMD the repo $subdir. Trying to continue..."
		popd >/dev/null
	done
}


main "$@"
