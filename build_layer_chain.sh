#!/usr/bin/env bash

REPO_WEB_URL='https://hub.docker.com/r/casaper/docker-ci-images-ruby-and-rails-repo'

. ./lib.sh
. ./build_layer_chain_options.sh

RUBY_VERSION="${RUBY_VERSION:-2.6}"
TAG_PREFIX="${SET_TAG_PREFIX:-ruby-}"
if [ "$SET_TAG_PREFIX" = "none" ]; then
  TAG_PREFIX=''
fi
BUNDLER_VERSION="${BUNDLER_VERSION:-skip}"

NODE_VERSION_INSTALL="${NODE_VERSION_INSTALL:-skip}"
FIREFOX_VERSION="${FIREFOX_VERSION:-skip}"
BUILD_CHROME_LAYER="${BUILD_CHROME_LAYER:-skip}"
EXTRA_DEBS="${EXTRA_DEBS:-skip}"
CUSTOM_EXTRA_DEBS_EXT="${CUSTOM_EXTRA_DEBS_EXT:-skip}"
NO_EXTRA_DEBS_IN_TAG="${NO_EXTRA_DEBS_IN_TAG:-skip}"
EXTRA_GEMS="${EXTRA_GEMS:-skip}"
FREETDS_VERSION="${FREETDS_VERSION:-skip}"
PUSH_TO_HUB="${PUSH_TO_HUB:-skip}"
PUSH_LAST_AS_LATEST="${PUSH_LAST_AS_LATEST:-skip}"
DOCKER_REPOSITORY="${CUSTOM_REPO:-casaper/docker-ci-images-ruby-and-rails-repo}"

# build base image
BASE_IMAGE_TAG="${DOCKER_REPOSITORY}:${TAG_PREFIX}${RUBY_VERSION}"

echo "Building base image with ${RUBY_VERSION} with docker image tag ${BASE_IMAGE_TAG}"
IMAGE_STACK_STRING="ruby:${RUBY_VERSION} with bundler ${BUNDLER_VERSION}"$'\n'"Tag: ${BASE_IMAGE_TAG}"$'\n\n'
docker build -t "$BASE_IMAGE_TAG" --build-arg "ruby_version=${RUBY_VERSION}" --build-arg "bundler_version=${BUNDLER_VERSION}" -f Dockerfile .
if [ "$PUSH_TO_HUB" == "1" ]; then push_to_docker_hub "$BASE_IMAGE_TAG"; fi

if [ "$NODE_VERSION_INSTALL" != 'skip' ]; then
  BASED_ON_TAG="$BASE_IMAGE_TAG"
  BASE_IMAGE_TAG="${BASE_IMAGE_TAG}-node${NODE_VERSION_INSTALL}"
  echo "Building node layer with version ${NODE_VERSION_INSTALL} with docker image tag ${BASE_IMAGE_TAG}"
  IMAGE_STACK_STRING="${IMAGE_STACK_STRING}Node version ${NODE_VERSION_INSTALL}"$'\n'"Tag: ${BASE_IMAGE_TAG}"$'\n\n'
  docker build -t "$BASE_IMAGE_TAG" --build-arg "base_image=${BASED_ON_TAG}" --build-arg "ci_node_version=${NODE_VERSION_INSTALL}" -f node.Dockerfile .
  if [ "$PUSH_TO_HUB" == "1" ]; then push_to_docker_hub "$BASE_IMAGE_TAG"; fi
fi

if [ "$FIREFOX_VERSION" != 'skip' ]; then
  BASED_ON_TAG="$BASE_IMAGE_TAG"
  BASE_IMAGE_TAG="${BASE_IMAGE_TAG}-firefox-${FIREFOX_VERSION}"
  echo "Building firefox layer with version ${FIREFOX_VERSION} with docker image tag ${BASE_IMAGE_TAG}"
  IMAGE_STACK_STRING="${IMAGE_STACK_STRING}Firefox version ${FIREFOX_VERSION}"$'\n'"Tag: ${BASE_IMAGE_TAG}"$'\n\n'
  docker build -t "$BASE_IMAGE_TAG" --build-arg "base_image=${BASED_ON_TAG}" --build-arg "firefox_version=${FIREFOX_VERSION}" -f firefox.Dockerfile .
  if [ "$PUSH_TO_HUB" == "1" ]; then push_to_docker_hub "$BASE_IMAGE_TAG"; fi
fi

if [ "$FREETDS_VERSION" != 'skip' ]; then
  BASED_ON_TAG="$BASE_IMAGE_TAG"
  BASE_IMAGE_TAG="${BASE_IMAGE_TAG}-freetds-${FREETDS_VERSION}"
  echo "Building FreeTDS layer with version ${FREETDS_VERSION} with docker image tag ${BASE_IMAGE_TAG}"
  IMAGE_STACK_STRING="${IMAGE_STACK_STRING}FreeTDS version ${FREETDS_VERSION}"$'\n'"Tag: ${BASE_IMAGE_TAG}"$'\n\n'
  docker build -t "$BASE_IMAGE_TAG" --build-arg "base_image=${BASED_ON_TAG}" --build-arg "freetds_version=${FREETDS_VERSION}" -f freetds.Dockerfile .
  if [ "$PUSH_TO_HUB" == "1" ]; then push_to_docker_hub "$BASE_IMAGE_TAG"; fi
fi

if [ "$BUILD_CHROME_LAYER" != 'skip' ]; then
  BASED_ON_TAG="$BASE_IMAGE_TAG"
  BASE_IMAGE_TAG="${BASE_IMAGE_TAG}-chrome"
  echo "Building chrome layer with docker image tag ${BASE_IMAGE_TAG}"
  IMAGE_STACK_STRING="${IMAGE_STACK_STRING}Google Chrome stable"$'\n'"Tag: ${BASE_IMAGE_TAG}"$'\n\n'
  docker build -t "$BASE_IMAGE_TAG" --build-arg "base_image=${BASED_ON_TAG}" -f chrome.Dockerfile .
  if [ "$PUSH_TO_HUB" == "1" ]; then push_to_docker_hub "$BASE_IMAGE_TAG"; fi
fi

if [ "$EXTRA_GEMS" != 'skip' ]; then
  BASED_ON_TAG="$BASE_IMAGE_TAG"
  BASE_IMAGE_TAG="${BASE_IMAGE_TAG}-extra-gems"
  echo "Building node layer with version ${EXTRA_GEMS} with docker image tag ${BASE_IMAGE_TAG}"
  IMAGE_STACK_STRING="${IMAGE_STACK_STRING}Node version ${EXTRA_GEMS}"$'\n'"Tag: ${BASE_IMAGE_TAG}"$'\n\n'
  docker build -t "$BASE_IMAGE_TAG" --build-arg "base_image=${BASED_ON_TAG}" --build-arg "extra_gems=${EXTRA_GEMS}" -f extra_gems.Dockerfile .
  if [ "$PUSH_TO_HUB" == "1" ]; then push_to_docker_hub "$BASE_IMAGE_TAG"; fi
fi

if [ "$EXTRA_DEBS" != 'skip' ]; then
  BASED_ON_TAG="$BASE_IMAGE_TAG"
  if [ "$NO_EXTRA_DEBS_IN_TAG" == 'no-tag' ]; then
    BASE_IMAGE_TAG="${BASE_IMAGE_TAG}-extra"
  else
    for DEB_NAME in $EXTRA_DEBS; do
      BASE_IMAGE_TAG="${BASE_IMAGE_TAG}-${DEB_NAME}"
    done
  fi
  echo "Building extra packages layer with docker image tag ${BASE_IMAGE_TAG}"
  echo "With the packages: ${EXTRA_DEBS}"
  IMAGE_STACK_STRING="${IMAGE_STACK_STRING}Extra packages: ${EXTRA_DEBS}"$'\n'"Tag: ${BASE_IMAGE_TAG}"$'\n\n'
  docker build -t "$BASE_IMAGE_TAG" --build-arg "base_image=${BASED_ON_TAG}" --build-arg "extra_debs=${EXTRA_DEBS}" -f extra_debs.Dockerfile .
  if [ "$PUSH_TO_HUB" == "1" ]; then push_to_docker_hub "$BASE_IMAGE_TAG"; fi
fi

if [ "$PUSH_LAST_AS_LATEST" == '1' ]; then
  echo "pushing as latest"
  docker tag "$BASE_IMAGE_TAG" "${DOCKER_REPOSITORY}:latest"
  docker push "${DOCKER_REPOSITORY}:latest"
fi

echo "Built the following Images:"
echo $'\n --- \n\n'
echo "$IMAGE_STACK_STRING"

exit 0
