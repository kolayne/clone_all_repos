#!/bin/bash

source common.sh

GH_USERNAME=""
GH_TOKEN=""

SNAPSHOT_ROOT_DIR=""
CLONE_FORKS=true
CLONE_EXPLICITLY_ACCESSIBLE=false
INCLUDE_ORGANIZATIONS=false
PROTOCOL=SSH

GIT_ARGS=""


usage() {
	echo -e "Usage: $0 <OPTIONS>... [-- <GIT_CLONE_ADDITIONAL_OPTIONS>...]"

	echo -e "\nRequired options:"
	echo -e "\t-u | --user <USERNAME> - GitHub username of either organization or user to clone repos of."
	echo -e "\t-o | --output-dir <SNAPSHOT_ROOT_DIR> - The root directory of a snapshot"

	echo -e "\nOther options:"
	echo -ne "\t-t | --token <TOKEN> - GitHub personal access token FOR THE USER <USERNAME>. "
	echo -e "Given the correct permissions, the token will give access to private repos/organizations"
	echo -e "\t--no-forks - Do not clone repos that are forks"
	echo -ne "\t-E | --include-explicitly-accessible - Clone not only repositories owned by user but all "
	echo -e "the repos user has explicit permissions (read,write,admin) to access (quoted from github)"
	echo -ne "\t-O | --include-organizations - If <USERNAME> is a user, then clone not only repositories "
	echo -ne "owned by it, but also those owned by organizations that the user belongs to. If <USERNAME> "
	echo -e "is an organization, this is an error. If token is not specified, this is an error"
	echo -ne "\t--http[s] - Clone repos via HTTPS instead of SSH. If private repos are to be cloned (with "
	echo -e "a token), this token will be used for the cloning itself"
	echo -e "\t-h | --help - Display this message"

	echo -ne "\nWhen cloning, \"GIT_CLONE_ADDITIONAL_OPTIONS\" will be passed to \`git clone\` before the "
	echo -e "arguments denoting url and output directory"

	exit 0
}


parse_args() {
	while [ -n "$1" ]; do
		case "$1" in
			-u | --user)
				shift
				GH_USERNAME="$1"
				[[ "${1:0:1}" = "-" ]] && die "Invalid username $1 (can't start with a hyphen)"
				;;

			-o | --output-dir)
				shift
				SNAPSHOT_ROOT_DIR="$1"
				[[ ! -d "$1" ]] && die "$1 does not exist, is not a directory or inaccessible"
				;;

			-t | --token)
				shift
				GH_TOKEN="$1"
				[[ "${1:0:1}" = "-" ]] && die "Invalid token $1 (can't start with a hyphen)"
				;;

			--no-forks) CLONE_FORKS=false ;;
			-E | --include-explicitly-accessible) CLONE_EXPLICITLY_ACCESSIBLE=true ;;
			-O | --include-organizations) INCLUDE_ORGANIZATIONS=true ;;
			--http | --https) PROTOCOL=HTTPS ;;

			-h | --help) usage ;;

			--) shift; GIT_ARGS="$@"; break ;;  # The rest is additional arguments to `git clone`

			*) die "Unknown argument $1" ;;
		esac

		shift
	done

	[[ -z "$GH_USERNAME" ]] && die "GitHub username must be specified (with --user)"
	[[ -z "$SNAPSHOT_ROOT_DIR" ]] && die "Snapshot root directory must be specified (with --output-dir)"
	[[ -z "$GH_TOKEN" ]] && [[ "$CLONE_EXPLICITLY_ACCESSIBLE" = true ]] && \
		die "Cannot clone explicitly accessible without token specified"
}


# $1 must be a json array of repos; if $2 is not empty, only repos with owner login "$2" will be returned
get_full_names_of_repos_from_json() {
	JQ_FILTER=".[]"
	if [[ "$CLONE_FORKS" = false ]]; then
		JQ_FILTER="$JQ_FILTER | select(.fork == false)"
	fi
	if [[ ! -z "$2" ]]; then
		JQ_FILTER="$JQ_FILTER | select((.owner.login | ascii_downcase) == (\"$2\" | ascii_downcase))"
	fi
	JQ_FILTER="$JQ_FILTER | .full_name"

	# Output of below is the return value
	echo "$1" | jq -er "$JQ_FILTER"
}


list_repos_of_user() {
	if [[ -z "$GH_TOKEN" ]]; then
		WHAT_TO_CURL="https://api.github.com/users/$GH_USERNAME/repos"
	else
		WHAT_TO_CURL="-u $GH_USERNAME:$GH_TOKEN https://api.github.com/user/repos"
	fi

	REPOS_JSON=$(curl $WHAT_TO_CURL) || \
		die "Couldn't retrieve the repositories list. Are the username/token correct?"

	if [[ "$CLONE_EXPLICITLY_ACCESSIBLE" = false ]]; then
		OWNER_FILTER="$GH_USERNAME"
	fi

	# Output of below is the return value
	get_full_names_of_repos_from_json "$REPOS_JSON" "$OWNER_FILTER" || \
		die "Failed to parse JSON. Incorrect username/token?"
}

list_repos_of_organizations() {
	if [[ -z "$GH_TOKEN" ]]; then
		WHAT_TO_CURL="https://api.github.com/users/$GH_USERNAME/orgs"
	else
		WHAT_TO_CURL="-u $GH_USERNAME:$GH_TOKEN https://api.github.com/user/orgs"
	fi

	ORGS_URLS=$(curl $WHAT_TO_CURL | jq -er '.[].url') || \
		die "Couldn't retrieve the list of organizations. Are the token permissions correct?"

	# Output of below is the return value
	for org_url in $ORGS_URLS; do
		REPOS_JSON=$(curl -u "$GH_USERNAME:$GH_TOKEN" "$org_url"/repos) || \
			die "Couldn't retrieve the repositories of organization $org_url"
		get_full_names_of_repos_from_json "$REPOS_JSON" || \
			die "Failed to parse JSON. Insufficient token permissions?"
	done
}

# $1 must be the list of full names of repos to clone. Will clone to current directory
clone_repos_by_full_name() {
	URL_PREFIX="git@github.com:"
	[[ "$PROTOCOL" = "HTTPS" ]] && URL_PREFIX="https://$GH_USERNAME:$GH_TOKEN@github.com/"

	for repo_full_name in $1; do
		# Only SSH cloning is supported at the moment
		git clone $GIT_ARGS "$URL_PREFIX$repo_full_name.git" "$repo_full_name" || \
			echo "FAILED TO CLONE repo $repo_full_name. Trying to continue..." >&2
	done
}


clone_all_needed_repos() {
	REPOS_LIST=$(list_repos_of_user) || die "Failed to list repositories of user"
	if [[ "$INCLUDE_ORGANIZATIONS" = true ]]; then
		REPOS_LIST="$REPOS_LIST"$'\n'$(list_repos_of_organizations) ||
			die "Failed to list repositories of organizations"
	fi

	# If both organizations and explcitily-accessible are included, there may be collisions. We don't want
	# to duplicate things twice
	REPOS_LIST=$(echo "$REPOS_LIST" | sort | uniq) || die '`... | sort | uniq` failed. Wtf?..'

	mkdir -p "$SNAPSHOT_ROOT_DIR" && cd "$SNAPSHOT_ROOT_DIR" || \
		die "Failed to enter the snapshot root directory"

	clone_repos_by_full_name "$REPOS_LIST"
}


main() {
	parse_args "$@"
	clone_all_needed_repos
}


main "$@"
