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
    'dev')  aws_env='sandbox' ;;
    'prod') aws_env='prod'    ;;
    *)
        echo "Bad environment ${environment}" >&2
        exit 1
        ;;
esac

$(dirname $0)/repo_branch.sh -b "${source_branch}" -r q-collect -u $user -v "${version}"

echo "Building ${version} for ${environment}"

exit 0
