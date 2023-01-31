#!/bin/false

# Common functions that are used by several scripts

die() {
        echo "$(basename "$0"): $1" >&2
        exit 1
}
