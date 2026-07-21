#!/bin/sh

source "$(dirname "$0")/_common"

SNAPSHOT_ROOT_DIR=""
GIT_ARGS=""


usage() {
	echo -e "Usage: $0 [-h|--help] <SNAPSHOT_ROOT_DIRECTORY> <GIT_COMMAND> [<ADDITIONAL_GIT_ARGS>...]"

	echo -e "\nThis will run the specified git command for each repository in the snapshot."
	echo 'Tip: use the `pull` or `fetch` commands to update the snapshot repositories.'

	exit 0
}


parse_args() {
	[[ "$1" = "--help" || "$1" = "-h" || "$2" = "--help" || "$2" = "-h" ]] && usage

	[[ -z "$1" ]] && \
		die "You have to specify the snapshot root directory as the first argument"
	[[ "${1:0:1}" = "-" ]] && \
		die "The directory name '$1' starts with a hyphen. Is that intended? If so, make it './$1'"
	[[ -d "$1" ]] ||
		die "'$1' is not a directory or is not accessible"

	SNAPSHOT_ROOT_DIR="$1"

	[[ -z "$2" ]] && \
		die "Git command must be specified as the second argument"

	shift 1

	GIT_ARGS="$@"
}


main() {
	parse_args "$@"
	cd "$SNAPSHOT_ROOT_DIR" || die "Failed to enter the directory $SNAPSHOT_ROOT_DIR"

	for subdir in */*/; do
		git -C "$subdir" $GIT_ARGS || \
			echo "Command failed for $subdir. Trying to continue..."
	done
}


main "$@"
