unzstd docker-image-debian11-repackage.tar.zst
docker load --input docker-image-debian11-repackage.tar
export SRC="/Users/gbustamante/workspace/clean/mozilla-central"
export TARGET="/builds/worker/checkouts/gecko"
export EXTRA_MOZHARNESS_CONFIG="{\"objdir\": \"obj-build\", \"repackage_config\": [{\"args\": [\"deb\", \"--arch\", \"x86_64\", \"--templates\", \"browser/installer/linux/app/debian\", \"--version\", \"117.0a1\", \"--build-number\", \"1\", \"--release-product\", \"None\", \"--release-type\", \"nightly\"], \"inputs\": {\"input\": \"target.tar.bz2\"}, \"output\": \"target.deb\"}]}"
docker run \
-it --mount src=$SRC,target=$TARGET,type=bind --name debian11-repackage-$(date +%s) \
--platform linux/amd64 \
--env GECKO_PATH=$TARGET --env MOZ_FETCHES_DIR="/builds/worker/fetches" --env UPLOAD_DIR="/builds/worker/artifacts" \
debian11-repackage
