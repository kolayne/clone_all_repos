# Common functions that are used by several scripts

die() {
        # Have to do it as a separate command because need to forward `"$0"` as a single argument,
        # but cannot then enquote `$(...)` itself
        PROG_NAME=$(basename "$0")

        echo "$PROG_NAME: $1" >&2
        exit 1
}
