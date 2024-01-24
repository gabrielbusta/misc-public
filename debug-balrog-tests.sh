#!/bin/bash

set -x
set -euo pipefail

export DOCKER_IMAGE_URL="https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/FIFCGTSoSM-Mzg7crJjYdQ/runs/0/artifacts/public%2Fimage.tar.zst"
export DOCKER_IMAGE_ZST_FILE="image.tar.zst"
export DOCKER_IMAGE="python3.11"
export CONTAINER_NAME=$DOCKER_IMAGE-$(date +%s)
export TARGET="/builds/worker/checkouts/vcs"
export SRC=$(pwd)

echo "Downloading compressed $DOCKER_IMAGE from $DOCKER_IMAGE_URL"
wget -O $DOCKER_IMAGE_ZST_FILE $DOCKER_IMAGE_URL

echo "Uncompressing $DOCKER_IMAGE_ZST_FILE"
unzstd "$DOCKER_IMAGE.tar.zst"
echo "Cleaning up $DOCKER_IMAGE_ZST_FILE"
rm $DOCKER_IMAGE_ZST_FILE

docker load --input "$DOCKER_IMAGE.tar"

docker run \
-it --mount src=$SRC,target=$TARGET,type=bind \
--name $CONTAINER_NAME \
--platform linux/amd64 \
$DOCKER_IMAGE
