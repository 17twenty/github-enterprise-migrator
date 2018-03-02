#!/usr/bin/env bash

echo "Migrator will dupe all your Github Repos into your Github Enterprise account"
echo "It uses the private user tokens with admin:* required for both accounts"

if [ -z "${GITHUB_PRIVATE_AUTH_TOKEN+xxx}" ];
then
 echo "GITHUB_PRIVATE_AUTH_TOKEN not defined"
 exit 1
fi

if [ -z "${GITHUB_ENTERPRISE_TOKEN+xxx}" ];
then
 echo "GITHUB_ENTERPRISE_TOKEN not defined"
 exit 1
fi

if [ -z "${GITHUB_PRIVATE_ORG+xxx}" ];
then
 echo "GITHUB_PRIVATE_ORG not defined"
 exit 1
fi
if [ -z "${GITHUB_ENTERPRISE_ORG+xxx}" ];
then
 echo "GITHUB_ENTERPRISE_ORG not defined"
 exit 1
fi
if [ -z "${GITHUB_ENTERPRISE_URI+xxx}" ];
then
 echo "GITHUB_ENTERPRISE_URI not defined"
 exit 1
fi


echo "It will start in 5 seconds (CTRL-C to cancel)..."
sleep 5

# Get a list of all the remote repos (using the AUTH_TOKEN for Github)
ALL_REPOS=$(curl -H "Authorization: token $GITHUB_PRIVATE_AUTH_TOKEN" https://api.github.com/orgs/$GITHUB_PRIVATE_ORG/repos?per_page=100)
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

    # Inject TOKEN after the https://
    p=8
    URL_TEMP="${URL_TEMP:0:p}$GITHUB_PRIVATE_AUTH_TOKEN@${URL_TEMP:p}"
    echo "Checking out the original..."
    git clone $URL_TEMP
    echo 
    echo "Creating new enterprise repo "
    curl -i -H "Authorization: token $GITHUB_ENTERPRISE_TOKEN"  -d '{"name": "'${REPO_NAMES[i]}'", "auto_init": false}'  https://$GITHUB_ENTERPRISE_URI/api/v3/orgs/$GITHUB_ENTERPRISE_ORG/repos 2>&1 /dev/null
    echo "Jumping in to repo..."
    pushd ${REPO_NAMES[i]}
    echo "Changing remote"
    git remote remove origin
    git remote add origin https://$GITHUB_ENTERPRISE_URI/$GITHUB_ENTERPRISE_ORG/${REPO_NAMES[i]}
    echo "Pushing to new remote"
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
