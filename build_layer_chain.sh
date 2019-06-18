#!/usr/bin/env bash
# set -xeuo pipefail

while test $# -gt 0; do
  package='build_layer_chain'
  case "$1" in
    -h|--help)
      echo "$package - build a chain of docker image layers for ruby ci"$'\n'
      echo "$package [options]"$'\n'
      echo 'options:'
      echo $'\t-h, --help\t\t\tshow brief help'
      echo $'\t--ruby-version=\t\tdefault is 2.5'
      echo $'\t--bundler-version=\t\tdefault is skip - installs default'
      echo $'\t--extra-gems=\t\tpreinstall extra gems into a docker layer'
      echo $'\t--extra-debs=\t\ta space separated list of extra debian packages to install'
      echo $'\t--extra-debs-tag-extra\t\tno package list in extra deps layer tag - use -extra instead'
      echo $'\t--extra-debs-custom-tag=\t\tdefine a custom tag to be added on extra debs layer'
      echo $'\t--node-version=\t\tbuild node layer with version - options 8, 9 or 10'
      echo $'\t--chrome\t\tbuild layer with google-chrome-stable'
      echo $'\t--firefox-version\t\tbuild layer with Firefox version. One of latest, beta-latest, esr-latest or specific from http://releases.mozilla.org/pub/firefox/releases/'
      echo $'\t--freetds-version=\t\tbuild layer with freetds version - see ftp://ftp.freetds.org/pub/freetds/stable/'

      exit 0
      ;;
    --ruby-version=*)
      RUBY_VERSION="${1//--ruby-version=}"
      echo "- base layer with ${RUBY_VERSION}"
      shift
      ;;
    --bundler-version=*)
      BUNDLER_VERSION="${1//--bundler-version=}"
      echo "- bundler version installed ${BUNDLER_VERSION}"
      shift
      ;;
    --extra-gems=*)
      EXTRA_GEMS="${1//--extra-gems=}"
      echo "- layer with extra gems preinstalled: ${EXTRA_GEMS}"
      shift
      ;;
    --node-version=*)
      NODE_VERSION_INSTALL="${1//--node-version=}"
      echo "- Node layer with version ${NODE_VERSION_INSTALL}"
      shift
      ;;
    --extra-debs=*)
      EXTRA_DEBS="${1//--extra-debs=}"
      echo "- layer with extra packages: ${EXTRA_DEBS}"
      shift
      ;;
    --extra-debs-tag-extra)
      NO_EXTRA_DEBS_IN_TAG="no-tag"
      shift
      ;;
    --extra-debs-custom-tag=*)
      CUSTOM_EXTRA_DEBS_EXT="${1//--extra-debs-custom-tag=}"
      echo "- layer with extra pachages: ${CUSTOM_EXTRA_DEBS_EXT}"
      shift
      ;;
    --chrome)
      BUILD_CHROME_LAYER="build"
      echo "-  Google Chrome stable layer"
      shift
      ;;
    --firefox-version=*)
      FIREFOX_TEMP="${1//--firefox-version=}"
      FIREFOX_VERSION="${FIREFOX_TEMP:-latest}"
      echo "- layer with Firefox ${FIREFOX_VERSION}"
      shift
      ;;
    --firefox)
      FIREFOX_VERSION="latest"
      echo "- layer with Firefox ${FIREFOX_VERSION}"
      shift
      ;;
    --freetds-version=*)
      FREETDS_VERSION="${1//--freetds-version=}"
      echo "- layer with FreeTDS ${FREETDS_VERSION}"
      shift
      ;;
    *)
      break
      ;;
  esac
done

RUBY_VERSION="${RUBY_VERSION:-2.5}"
BUNDLER_VERSION="${BUNDLER_VERSION:-skip}"

NODE_VERSION_INSTALL="${NODE_VERSION_INSTALL:-skip}"
FIREFOX_VERSION="${FIREFOX_VERSION:-skip}"
BUILD_CHROME_LAYER="${BUILD_CHROME_LAYER:-skip}"
EXTRA_DEBS="${EXTRA_DEBS:-skip}"
CUSTOM_EXTRA_DEBS_EXT="${CUSTOM_EXTRA_DEBS_EXT:-skip}"
NO_EXTRA_DEBS_IN_TAG="${NO_EXTRA_DEBS_IN_TAG:-skip}"
EXTRA_GEMS="${EXTRA_GEMS:-skip}"
FREETDS_VERSION="${FREETDS_VERSION:-skip}"

echo "FreeTDS version ${FREETDS_VERSION}"

# build base image
BASE_IMAGE_TAG="git.panter.ch:5001/panter/gitlab-ci-docker-images/ruby-and-rails:ruby-${RUBY_VERSION}"
echo "Building base image with ${RUBY_VERSION} with docker image tag ${BASE_IMAGE_TAG}"
IMAGE_STACK_STRING="ruby:${RUBY_VERSION} with bundler ${BUNDLER_VERSION}"$'\n'"Tag: ${BASE_IMAGE_TAG}"$'\n\n'
docker build -t "$BASE_IMAGE_TAG" --build-arg "ruby_version=${RUBY_VERSION}" --build-arg "bundler_version=${BUNDLER_VERSION}" -f Dockerfile .

if [ "$NODE_VERSION_INSTALL" != 'skip' ]; then
  BASED_ON_TAG="$BASE_IMAGE_TAG"
  BASE_IMAGE_TAG="${BASE_IMAGE_TAG}-node${NODE_VERSION_INSTALL}"
  echo "Building node layer with version ${NODE_VERSION_INSTALL} with docker image tag ${BASE_IMAGE_TAG}"
  IMAGE_STACK_STRING="${IMAGE_STACK_STRING}Node version ${NODE_VERSION_INSTALL}"$'\n'"Tag: ${BASE_IMAGE_TAG}"$'\n\n'
  docker build -t "$BASE_IMAGE_TAG" --build-arg "base_image=${BASED_ON_TAG}" --build-arg "ci_node_version=${NODE_VERSION_INSTALL}" -f node.Dockerfile .
fi

if [ "$FIREFOX_VERSION" != 'skip' ]; then
  BASED_ON_TAG="$BASE_IMAGE_TAG"
  BASE_IMAGE_TAG="${BASE_IMAGE_TAG}-firefox-${FIREFOX_VERSION}"
  echo "Building firefox layer with version ${FIREFOX_VERSION} with docker image tag ${BASE_IMAGE_TAG}"
  IMAGE_STACK_STRING="${IMAGE_STACK_STRING}Firefox version ${FIREFOX_VERSION}"$'\n'"Tag: ${BASE_IMAGE_TAG}"$'\n\n'
  docker build -t "$BASE_IMAGE_TAG" --build-arg "base_image=${BASED_ON_TAG}" --build-arg "firefox_version=${FIREFOX_VERSION}" -f firefox.Dockerfile .
fi


if [ "$FREETDS_VERSION" != 'skip' ]; then
  BASED_ON_TAG="$BASE_IMAGE_TAG"
  BASE_IMAGE_TAG="${BASE_IMAGE_TAG}-freetds-${FREETDS_VERSION}"
  echo "Building FreeTDS layer with version ${FREETDS_VERSION} with docker image tag ${BASE_IMAGE_TAG}"
  IMAGE_STACK_STRING="${IMAGE_STACK_STRING}FreeTDS version ${FREETDS_VERSION}"$'\n'"Tag: ${BASE_IMAGE_TAG}"$'\n\n'
  docker build -t "$BASE_IMAGE_TAG" --build-arg "base_image=${BASED_ON_TAG}" --build-arg "freetds_version=${FREETDS_VERSION}" -f freetds.Dockerfile .
fi

if [ "$BUILD_CHROME_LAYER" != 'skip' ]; then
  BASED_ON_TAG="$BASE_IMAGE_TAG"
  BASE_IMAGE_TAG="${BASE_IMAGE_TAG}-chrome"
  echo "Building chrome layer with docker image tag ${BASE_IMAGE_TAG}"
  IMAGE_STACK_STRING="${IMAGE_STACK_STRING}Google Chrome stable"$'\n'"Tag: ${BASE_IMAGE_TAG}"$'\n\n'
  docker build -t "$BASE_IMAGE_TAG" --build-arg "base_image=${BASED_ON_TAG}" -f chrome.Dockerfile .
fi

if [ "$EXTRA_GEMS" != 'skip' ]; then
  BASED_ON_TAG="$BASE_IMAGE_TAG"
  BASE_IMAGE_TAG="${BASE_IMAGE_TAG}-extra-gems"
  echo "Building node layer with version ${EXTRA_GEMS} with docker image tag ${BASE_IMAGE_TAG}"
  IMAGE_STACK_STRING="${IMAGE_STACK_STRING}Node version ${EXTRA_GEMS}"$'\n'"Tag: ${BASE_IMAGE_TAG}"$'\n\n'
  docker build -t "$BASE_IMAGE_TAG" --build-arg "base_image=${BASED_ON_TAG}" --build-arg "extra_gems=${EXTRA_GEMS}" -f extra_gems.Dockerfile .
fi

if [ "$EXTRA_DEBS" != 'skip' ]; then
  BASED_ON_TAG="$BASE_IMAGE_TAG"
  if [ "$NO_EXTRA_DEBS_IN_TAG" == 'no-tag' ]; then
    BASE_IMAGE_TAG="${BASE_IMAGE_TAG}-extra"
  fi
  if [ "$CUSTOM_EXTRA_DEBS_EXT" != 'skip' ]; then
    BASE_IMAGE_TAG="${BASE_IMAGE_TAG}${CUSTOM_EXTRA_DEBS_EXT}"
  fi
  if [ "$CUSTOM_EXTRA_DEBS_EXT" == 'skip' ] && [ "$NO_EXTRA_DEBS_IN_TAG" != 'no-tag' ]; then
    for DEB_NAME in $EXTRA_DEBS; do
      BASE_IMAGE_TAG="${BASE_IMAGE_TAG}-${DEB_NAME}"
    done
  fi
  echo "Building extra packages layer with docker image tag ${BASE_IMAGE_TAG}"
  echo "With the packages: ${EXTRA_DEBS}"
  IMAGE_STACK_STRING="${IMAGE_STACK_STRING}Extra packages: ${EXTRA_DEBS}"$'\n'"Tag: ${BASE_IMAGE_TAG}"$'\n\n'
  docker build -t "$BASE_IMAGE_TAG" --build-arg "base_image=${BASED_ON_TAG}" --build-arg "extra_debs=${EXTRA_DEBS}" -f extra_debs.Dockerfile .
fi

echo "Built the following Images:"$'\n\n'
echo "$IMAGE_STACK_STRING"
