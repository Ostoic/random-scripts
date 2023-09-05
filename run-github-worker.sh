#!/bin/bash

GITHUB_REPO="https://github.com/Ostoic/whispe-rs-types"

run-worker() {
	USER=$1
	WORKER_TOKEN=$2

	ssh $USER@ci-server "cd actions-runner && config.cmd remove --local && config.cmd --url $GITHUB_REPO --token $WORKER_TOKEN --work _work$RANDOM --name devops$RANDOM --unattended --ephemeral && run.cmd"
}

run-worker $1 $2
