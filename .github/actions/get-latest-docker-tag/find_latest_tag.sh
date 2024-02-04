#!/usr/bin/env bash

die () {
    echo "find-latest-tag.sh: $@"
    exit 1
}

get_all_tags() {
    # get token ('{"token":"***"}' -> '***')
    TOKEN="$(
    curl -S -s "https://ghcr.io/token?scope=repository:${1}:pull" |
    awk -F'"' '$0=$4'
    )"

    # get tags
    curl -S -s -H "Authorization: Bearer ${TOKEN}" "https://ghcr.io/v2/${1}/tags/list" 2> /dev/null | jq '."tags"[]' 2> /dev/null
}

###################################################

image=${1}

all_tags="$(get_all_tags ${image} \
    | sed 's/"//g' \
    | grep -vE '^latest$' \
)"

query=${2}
if [ -z "${query}" ]; then
    query=''
fi

tag="$(printf "%s\n" $all_tags \
    | grep -oE "${query}" \
    | sort -V \
    | tail -1 \
)"

if [ -z "${tag}" ]; then
    die "cannot find tag matching regex: ${2}"
fi

echo "tag=${tag}" >> $GITHUB_OUTPUT
