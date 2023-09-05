#!/bin/bash

REPO_PATH="https://github.com/ostoic/$GITHUB_REPO"
#$GITHUB_BEARER

create-worker-token() {
	REPO=$1
	RESULT=$(curl -sL \
		-X POST \
		-H "Accept: application/vnd.github+json" \
		-H "Authorization: Bearer $GITHUB_BEARER" \
		-H "X-GitHub-Api-Version: 2022-11-28" \
		https://api.github.com/repos/Ostoic/$REPO/actions/runners/registration-token 2>&1)

	echo -n $RESULT | xargs | cut -d' ' -f3 | tr -dc '[a-zA-Z0-9]'
}

run-worker() {
	USER=$1
	WORKER_TOKEN=$2

	ssh $USER@ci-server "cd actions-runner && config.cmd remove --local && config.cmd --url $REPO_PATH --token $WORKER_TOKEN --work _workt --name devops$RANDOM --unattended --ephemeral && run.cmd"
}

set -e
TOKEN=$(create-worker-token $GITHUB_REPO)
run-worker $1 $TOKEN
