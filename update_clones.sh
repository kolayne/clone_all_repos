#!/bin/bash

GIT_CMD=""
ROOT_CLONE_DIR=""
ADDITIONAL_GIT_ARGS=""


usage() {
	echo -e "Usage: $0 [--help] pull|fetch <ROOT_CLONE_DIRECTORY> [<ADDITIONAL_GIT_ARGS>...]"

	echo -ne "\nThis will either pull or fetch all the repositories located in "
	echo -e "<ROOT_CLONE_DIRECTORY> (not recursively, only the first-level subdirectories)"

	exit 0
}


parse_args() {
	[[ "$1" = "--help" || "$2" = "--help" ]] && usage

	if [[ "$1" = "fetch" || "$1" = "pull" ]]; then
		GIT_CMD="$1"
	else
		die "The first argument must be either pull or fetch"
	fi

	ROOT_CLONE_DIR="$2"

	shift 2

	ADDITIONAL_GIT_ARGS="$@"
}


main() {
	parse_args "$@"
	cd "$ROOT_CLONE_DIR" || die "Failed to enter the directory $ROOT_CLONE_DIR"

	for subdir in */*/; do
		pushd "$subdir" && git "$GIT_CMD" $ADDITIONAL_GIT_ARGS || \
			echo "FAILED TO $GIT_CMD the repo $subdir. Trying to continue..."
		popd >/dev/null
	done
}


main "$@"
