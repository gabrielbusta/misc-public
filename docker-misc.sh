unzstd docker-image-debian11-repackage.tar.zst
docker load --input docker-image-debian11-repackage.tar
export SRC="/Users/gbustamante/workspace/clean/mozilla-central"
export TARGET="/builds/worker/checkouts/gecko"
docker run \
-it --mount src=$SRC,target=$TARGET,type=bind --name debian11-repackage-$(date +%s) \
--platform linux/amd64 \
--env GECKO_PATH=$TARGET --env MOZ_FETCHES_DIR="/builds/worker/fetches" --env UPLOAD_DIR="/builds/worker/artifacts" \
debian11-repackage
