export DOCKER_IMAGE_URL="https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/FIFCGTSoSM-Mzg7crJjYdQ/runs/0/artifacts/public%2Fimage.tar.zst"
export DOCKER_IMAGE="python3.11"
export CONTAINER_NAME=$DOCKER_IMAGE-$(date +%s)
export TARGET="/builds/worker/checkouts/vcs"
export SRC=$(pwd)

wget -O image.tar.zst $DOCKER_IMAGE_URL

unzstd "$DOCKER_IMAGE.tar.zst"
docker load --input "$DOCKER_IMAGE.tar"

docker run \
-it --mount src=$SRC,target=$TARGET,type=bind \
--name $CONTAINER_NAME \
--platform linux/amd64 \
$DOCKER_IMAGE
