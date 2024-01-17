export DOCKER_IMAGE="debian12-repackage"

unzstd "$DOCKER_IMAGE.tar.zst"
docker load --input "$DOCKER_IMAGE.tar"

export CONTAINER_NAME=$DOCKER_IMAGE-$(date +%s)
export SRC=$(pwd)
export TARGET="/builds/worker/checkouts/gecko"
# app
export EXTRA_MOZHARNESS_CONFIG="{\"objdir\": \"obj-build\", \"repackage_config\": [{\"args\": [\"deb\", \"--arch\", \"x86_64\", \"--templates\", \"browser/installer/linux/app/debian\", \"--version\", \"117.0a1\", \"--build-number\", \"1\", \"--release-product\", \"None\", \"--release-type\", \"nightly\"], \"inputs\": {\"input\": \"target.tar.bz2\"}, \"output\": \"target.deb\"}]}"
#l10n
# export EXTRA_MOZHARNESS_CONFIG="{\"objdir\": \"obj-build\", \"repackage_config\": [{\"args\": [\"deb-l10n\", \"--version\", \"119.0a1\", \"--build-number\", \"1\", \"--templates\", \"browser/installer/linux/langpack/debian\"], \"inputs\": {\"input-tar-file\": \"target.tar.bz2\", \"input-xpi-file\": \"target.langpack.xpi\"}, \"output\": \"target.langpack.deb\"}]}"

docker run \
-it --mount src=$SRC,target=$TARGET,type=bind \
--name $CONTAINER_NAME \
--platform linux/amd64 \
--env GECKO_PATH=$TARGET \
--env MOZ_FETCHES_DIR="/builds/worker/fetches" \
--env UPLOAD_DIR="/builds/worker/artifacts" \
--env EXTRA_MOZHARNESS_CONFIG=$EXTRA_MOZHARNESS_CONFIG \
$DOCKER_IMAGE
