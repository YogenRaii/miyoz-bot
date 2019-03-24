#!/usr/bin/env bash

set -e
set -u

tag=false

while getopts b:r:t:u:v: arg ; do
    case $arg in
        'b')  source_branch=$OPTARG  ;;
        'r')  repo=$OPTARG           ;;
        'u')  user=$OPTARG           ;;
        'v')  version=$OPTARG        ;;
    esac
done

branch="release/${version}"

cd $HOME

function clean_up_repo() {
    repo_dir=$1
    cd ~/${repo_dir} &>/dev/null
    git clean -f &>/dev/null
    git reset HEAD^ --hard &>/dev/null
    git checkout develop &>/dev/null
    git fetch --prune --all &>/dev/null
    for _branch in $(git branch | grep -v develop | awk '{print $NF}'); do
        git branch -D $_branch
    done
    git config user.name "${user}"
    git checkout ${source_branch} &>/dev/null
    git pull &>/dev/null
    cd
}

function rev_version() {
    case $repo in
        'q-collect')
            find . -type f -name "pom.xml" -exec sed -ie "s,1\.[0-9]\.[0-9]\.x,${version}," {}  \; &>/dev/null
            ;;
        'q-collect-ui')
            sed -ie "s/1\.[0-9][0-9]\.[0-9]-[0-9x]/${version}/" package.json  &>/dev/null
            ;;
        *)
            echo "ERROR! I don't know how to rev the version for ${repo}!"
            exit 1
            ;;
    esac
    return 0
}

echo "Cleaning up Repo"
if [[ ! -d $repo ]]; then
    ssh-keyscan github.com 2>&1 >> ~/.ssh/known_hosts
    git clone https://github.com/miyozinc/q-collect.git &>/dev/null
fi

clean_up_repo $repo

cd ~/$repo &>/dev/null
if [[ $(git branch -r | grep "${branch}" | wc -l) -eq 0 ]]; then
    echo "Cutting branch ${branch}"
    git checkout -b "${branch}" &>/dev/null
    echo "Revving version to ${version}"
    rev_version
    git add -u &>/dev/null
    git -c user.email='miyozinc@gmail.com' commit -m 'revving version' &>/dev/null
    git push -u origin "${branch}" &>/dev/null
    if [[ $tag = true ]]; then
        git tag v$version &>/dev/null
        git push origin v$version &>/dev/null
    fi
else
    echo "Branch already exists on origin"
fi

exit 0
