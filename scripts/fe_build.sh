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

$(dirname $0)/repo_branch.sh -b "${source_branch}" -r q-collect-ui -u $user -v "${version}"

echo "Building and deploying ${version} to ${environment}:"

body="{
  \"request\": {
    \"message\": \"Build from ${branch} triggered by ${user}\",
    \"branch\": \"${branch}\",
    \"config\": {
      \"merge_mode\":[\"replace\"],
      \"env\": {
        \"global\": [
          \"deploy_env=${environment}\"
        ]
      },
      \"before_script\": \"chmod +x ./travis/scripts/deploy.sh\",
      \"script\": \"./travis/scripts/deploy.sh\",
      \"deploy\": {
        \"provider\": \"s3\",
        \"access_key_id\": \"${aws_access_key_id}\",
        \"secret_access_key\":\"${aws_secret_access_key}\",
        \"bucket\":\"q-collect\",
        \"skip_cleanup\" : true,
        \"local_dir\": \"build\",
        \"upload_dir\": \"q-collect-web-${environment}\"
      }
    }
  }
}"

#TRAVIS_API_TOKEN="${TRAVIS_API_TOKEN}"

curl --silent --output /dev/null -X POST \
 -H "Content-Type: application/json" \
 -H "Accept: application/json" \
 -H "Travis-API-Version: 3" \
 -H "Authorization: token ${TRAVIS_API_TOKEN}" \
 -d "$body" \
 https://api.travis-ci.com/repo/miyozinc%2Fq-collect-ui/requests


exit 0
