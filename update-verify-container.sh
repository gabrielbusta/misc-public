export DOCKER_IMAGE="update-verify"
export DOCKER_IMAGE_URL="https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/VECQqjQoSCuXFGdWNsnggQ/runs/0/artifacts/public%2Fimage.tar.zst"
export CONTAINER_NAME=$DOCKER_IMAGE-$(date +%s)
export TARGET="/builds/worker/checkouts/gecko"
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
rm "$DOCKER_IMAGE.tar"
echo "Running a $CONTAINER_NAME container using the $DOCKER_IMAGE image as the worker user..."
echo "Mouting $SRC onto $TARGET in $CONTAINER_NAME"

docker run \
-it --mount src=$SRC,target=$TARGET,type=bind \
--user worker \
--name $CONTAINER_NAME \
--platform linux/amd64 \
--env GECKO_PATH=$TARGET \
--env MOZ_FETCHES_DIR="/builds/worker/fetches" \
--env UPLOAD_DIR="/builds/worker/artifacts" \
--env EXTRA_MOZHARNESS_CONFIG="$EXTRA_MOZHARNESS_CONFIG" \
$DOCKER_IMAGE
