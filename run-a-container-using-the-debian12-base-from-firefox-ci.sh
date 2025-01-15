# This script runs a container using the debian12-base image from Firefox CI and mounts the current directory (presumably a gecko checkout) onto /builds/worker/checkouts/gecko
export DOCKER_IMAGE="debian12-base"
export DOCKER_IMAGE_URL="https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/XY2zDpC5T6WqElwTvl9QdQ/runs/0/artifacts/public%2Fimage.tar.zst"
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
# app
export EXTRA_MOZHARNESS_CONFIG="{\"objdir\": \"obj-build\", \"repackage_config\": [{\"args\": [\"deb\", \"--arch\", \"x86_64\", \"--templates\", \"browser/installer/linux/app/debian\", \"--version\", \"117.0a1\", \"--build-number\", \"1\", \"--release-product\", \"None\", \"--release-type\", \"nightly\"], \"inputs\": {\"input\": \"target.tar.bz2\"}, \"output\": \"target.deb\"}]}"
#l10n
# export EXTRA_MOZHARNESS_CONFIG="{\"objdir\": \"obj-build\", \"repackage_config\": [{\"args\": [\"deb-l10n\", \"--version\", \"119.0a1\", \"--build-number\", \"1\", \"--templates\", \"browser/installer/linux/langpack/debian\"], \"inputs\": {\"input-tar-file\": \"target.tar.bz2\", \"input-xpi-file\": \"target.langpack.xpi\"}, \"output\": \"target.langpack.deb\"}]}"

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
