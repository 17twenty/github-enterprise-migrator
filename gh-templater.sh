#!/usr/bin/env bash


if [ -z "${GITHUB_AUTH_TOKEN+xxx}" ];
then
 echo "GITHUB_AUTH_TOKEN not defined"
 exit 1
fi
if [ -z "${GITHUB_ORG+xxx}" ];
then
 echo "GITHUB_ORG not defined"
 exit 1
fi
if [ -z "${GITHUB_URI+xxx}" ];
then
 echo "GITHUB_URI not defined"
 exit 1
fi

if [ ! -d ".github" ]; then
  echo "Couldn't find a .github folder of your templates - bailing!"
  exit 1
fi

echo "It will start in 5 seconds (CTRL-C to cancel)..."
sleep 5

# TODO: If it's regular github, we use /orgs/ if it's enterprise it's /api/v3/orgs

# Get a list of all the remote repos (using the AUTH_TOKEN for Github)
ALL_REPOS=$(curl -s -H "Authorization: token $GITHUB_AUTH_TOKEN" https://$GITHUB_URI/api/v3/orgs/$GITHUB_ORG/repos)
REPO_NAMES_STRING=$(echo $ALL_REPOS | jq '.[] | .name' | sed 's/"//g')
REPO_HTTPS_STRING=$(echo $ALL_REPOS | jq '.[] | .clone_url'| sed 's/"//g')

set -f # avoid globbing / expansion of *
REPO_NAMES=(${REPO_NAMES_STRING// / })
REPO_HTTPS=(${REPO_HTTPS_STRING// / })

# For each of the repos - grab the name, the code and create the enterprise version
for i in "${!REPO_NAMES[@]}"
do
    echo "Cloning ${REPO_HTTPS[i]}..."
    URL_TEMP=${REPO_HTTPS[i]}

    # # Inject TOKEN after the https://
    p=8
    URL_TEMP="${URL_TEMP:0:p}$GITHUB_PRIVATE_AUTH_TOKEN@${URL_TEMP:p}"
    git clone --depth 1 $URL_TEMP
    echo "Jumping in to repo..."
    pushd ${REPO_NAMES[i]}
    echo "Cleaning up and copying in template..."
    rm -rf .github || true
    cp -v ../.github .
    echo "Pushing to new remote"
    git add .
    git commit -am "Autoinjected Github Templates"
    git push origin master
    EC=$?
    if [ $EC -eq 0 ]; then
        echo "Pushing ${REPO_NAMES[i]} failed - you will need to push it yourself"
    fi
    echo "Popping"
    popd
    # echo "$i=>${REPO_NAMES[i]} = ${REPO_HTTPS[i]}"
done

exit 0
