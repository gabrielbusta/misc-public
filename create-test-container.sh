#!/bin/bash

# IMPORTRANT: RUN THIS SCRIPT IN THE "balrog" REPOSITORY!
# It will create a container using the CI's test image, mount your local balrog clone at /builds/worker/checkouts/vcs,
# and drop you into a bash shell inside of the container in that directory. From there you can
# run the test in the container: https://github.com/gabrielBusta/misc-public/blob/main/in-test-container.sh

set -x
set -euo pipefail

export DOCKER_IMAGE="python3.11"
export DOCKER_IMAGE_URL="https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/FIFCGTSoSM-Mzg7crJjYdQ/runs/0/artifacts/public%2Fimage.tar.zst"
export CONTAINER_NAME=$DOCKER_IMAGE-$(date +%s)
export TARGET="/builds/worker/checkouts/vcs"
export SRC=$(pwd)

echo "Downloading compressed $DOCKER_IMAGE from $DOCKER_IMAGE_URL"
wget -O "$DOCKER_IMAGE.tar.zst" $DOCKER_IMAGE_URL

echo "Uncompressing $DOCKER_IMAGE.tar.zst"
unzstd "$DOCKER_IMAGE.tar.zst"
echo "Cleaning up $DOCKER_IMAGE.tar.zst"
rm "$DOCKER_IMAGE.tar.zst"

echo "Loading $DOCKER_IMAGE.tar"
docker load --input "$DOCKER_IMAGE.tar"
echo "Cleaning up $DOCKER_IMAGE.tar"

docker run \
-it --mount src=$SRC,target=$TARGET,type=bind \
--name $CONTAINER_NAME \
--platform linux/amd64 \
-w $TARGET \
--rm \
$DOCKER_IMAGE
