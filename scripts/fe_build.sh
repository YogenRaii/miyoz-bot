#!/usr/bin/env bash

set -e
set -u

while getopts b:e:u:v: arg ; do
    case $arg in
        'b')  source_branch=$OPTARG  ;;
        'e')  environment=$OPTARG    ;;
        'u')  user=$OPTARG           ;;
        'v')  version=$OPTARG        ;;
    esac
done

branch="release/${version}"

case "${environment}" in
    'dev') ;;
    'prod') ;;
    *)
        echo "Bad environment ${environment}" >&2
        exit 1
        ;;
esac

if [[ "${source_branch}" = 'develop' ]]; then
    $(dirname $0)/repo_branch.sh -b "${source_branch}" -r q-collect-ui -u $user -v "${version}"
else
    $(dirname $0)/repo_branch.sh -b "${source_branch}" -r q-collect-ui -u $user -v "${version}"
fi

echo "Building and deploying ${version} to ${environment}:"

exit 0
