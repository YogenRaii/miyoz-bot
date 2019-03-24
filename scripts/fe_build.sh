#!/usr/bin/env bash

set -e
set -u

while getopts b:e:p:t:u:v: arg ; do
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
curl -sk --connect-timeout 5 "https://gbi.auto.nikecloud.com/job/ICONS/job/nikeGBIPUI/job/FrontendPipeline/job/01_build/buildWithParameters?token=icon-slacker&DEPLOY_ENV=$(echo "${environment}" | tr [a-z] [A-Z])&BRANCH=${branch}&ARCHIVE=true&DEPLOY=true"
curl -sk --connect-timeout 5 "https://gbi.auto.nikecloud.com/job/ICONS/job/brand-icon-ui/job/02_Build/buildWithParameters?token=icon-slacker&DEPLOY_ENV=$(echo "${environment}" | tr [a-z] [A-Z])&BRANCH=${branch}"

exit 0
