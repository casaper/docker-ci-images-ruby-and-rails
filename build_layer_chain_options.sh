#!/usr/bin/env bash

. ./lib.sh

while test $# -gt 0; do
  package='build_layer_chain.sh'
  case "$1" in
  -h | --help)
    echo -e $'\n'"${BOLD}${package}${SET} - build a chain of docker image layers for ruby ci"$'\n'
    echo -e "${BOLD}Usage${SET}: ./$package [options]"
    echo -e ''
    echo -e "${BOLD}options:${SET}"$'\n'
    HELP_INDENT='                             '

    display_help_option "$HELP_INDENT" 'Show this help' 'h, --help'

    TEXT='Default is 2.6. See https://hub.docker.com/_/ruby for available base images.'
    display_help_option "$HELP_INDENT" "$TEXT" 'ruby-version' '=' '2.6.5'

    TEXT='Install a specific bundler version.'$'\n'
    TEXT="${TEXT}${HELP_INDENT}See 'tail -n 2 Gemfile.lock' in the project your building your image for."
    display_help_option "$HELP_INDENT" "$TEXT" 'bundler-version' '=' '1.17.3'

    TEXT='Build node layer with version - options 8.x, 10.x, 12.x'$'\n'
    TEXT="${TEXT}${HELP_INDENT}Or any of the ones here: https://j.mp/node-versions. Just exclude 'setup_'"$'\n'
    TEXT="${TEXT}${HELP_INDENT}Will install yarn for that node version with 'npm install -g yarn'"
    display_help_option "$HELP_INDENT" "$TEXT" 'node-version' '=' '10.x'

    TEXT='Build layer with google-chrome-stable'
    display_help_option "$HELP_INDENT" "$TEXT" 'chrome'

    TEXT='Build layer with Firefox [latest|beta-latest|esr-latest] '$'\n'
    TEXT="${TEXT}${HELP_INDENT}Or specific version https://releases.mozilla.org/pub/firefox/releases/"
    display_help_option "$HELP_INDENT" "$TEXT" 'firefox-version' '=' 'latest'

    TEXT='Space separated list of gems to pre-install in a docker layer.'$'\n'
    TEXT="${TEXT}${HELP_INDENT}Could be used for gems you don't have in the projects bundle."
    display_help_option "$HELP_INDENT" "$TEXT" 'extra-gems' '=' "'heroku pry'"

    TEXT='Space separated list of apt packages.'$'\n'
    TEXT="${TEXT}${HELP_INDENT}This would do 'apt-get install --no-install-recommends xy xz'"$'\n'
    TEXT="${TEXT}${HELP_INDENT}By default the whole list of debs you add is added to the image tag:"$'\n'
    TEXT="${TEXT}${HELP_INDENT}casaper/docker-ci-images-ruby-and-rails-repo:ruby-2.6.5-xy-xz"
    display_help_option "$HELP_INDENT" "$TEXT" 'extra-debs' '=' "'xy xz'"

    TEXT='Push all built tags to docker hub'$'\n'
    TEXT="${TEXT}${HELP_INDENT}See ${REPO_WEB_URL}"
    display_help_option "$HELP_INDENT" "$TEXT" 'push-to-hub'

    TEXT='Push the last built image as well as latest tag.'$'\n'
    TEXT="${TEXT}${HELP_INDENT}This enables --push-to-hub flag allongside"
    display_help_option "$HELP_INDENT" "$TEXT" 'push-last-as-latest'

    TEXT='Change the repository to something else:'$'\n'
    TEXT="${TEXT}${HELP_INDENT}abc/xyz:ruby-2.6.5-node10"
    display_help_option "$HELP_INDENT" "$TEXT" 'custom-repo' '=' 'abc/xyz'

    TEXT="Don't add a tag prefix. Ruby version number will be start of tag: "$'\n'
    TEXT="${TEXT}${HELP_INDENT}casaper/docker-ci-images-ruby-and-rails-repo:2.6.5-node10"
    display_help_option "$HELP_INDENT" "$TEXT" 'tag-prefix' '=' 'none'

    TEXT='Change default tag prefix "ruby-" to custom string:'$'\n'
    TEXT="${TEXT}${HELP_INDENT}casaper/docker-ci-images-ruby-and-rails-repo:custom-2.6.5-node10"
    display_help_option "$HELP_INDENT" "$TEXT" 'tag-prefix' '=' 'custom-'

    TEXT="No deb list in tag. Add only '-extra' instead"$'\n'
    TEXT="${TEXT}${HELP_INDENT}Only has an effect in combination with '--extra-debs='."
    display_help_option "$HELP_INDENT" "$TEXT" 'extra-debs-tag-extra'

    TEXT='Build layer that has freetds of given version.'$'\n'
    TEXT="${TEXT}${HELP_INDENT}This is needed when the image needs to access a MS-SQLServer."$'\n'
    TEXT="${TEXT}${HELP_INDENT}Available versions: ftp://ftp.freetds.org/pub/freetds/stable/"
    display_help_option "$HELP_INDENT" "$TEXT" 'freetds-version' '=' '1.1.20'

    exit 0
    ;;
    # END of help output

  ## Option parsing and setting
  --ruby-version=*)
    RUBY_VERSION="${1//--ruby-version=/}"
    echo "- base layer with ${RUBY_VERSION}"
    shift
    ;;
  --bundler-version=*)
    BUNDLER_VERSION="${1//--bundler-version=/}"
    echo "- bundler version installed ${BUNDLER_VERSION}"
    shift
    ;;
  --extra-gems=*)
    EXTRA_GEMS="${1//--extra-gems=/}"
    echo "- layer with extra gems preinstalled: ${EXTRA_GEMS}"
    shift
    ;;
  --node-version=*)
    NODE_VERSION_INSTALL="${1//--node-version=/}"
    echo "- Node layer with version ${NODE_VERSION_INSTALL}"
    shift
    ;;
  --extra-debs=*)
    EXTRA_DEBS="${1//--extra-debs=/}"
    echo "- layer with extra packages: ${EXTRA_DEBS}"
    shift
    ;;
  --extra-debs-tag-extra)
    NO_EXTRA_DEBS_IN_TAG="no-tag"
    shift
    ;;
  --extra-debs-set-tag=*)
    CUSTOM_EXTRA_DEBS_EXT="${1//--extra-debs-set-tag=/}"
    echo "- layer with extra pachages: ${CUSTOM_EXTRA_DEBS_EXT}"
    shift
    ;;
  --chrome)
    BUILD_CHROME_LAYER="build"
    echo "-  Google Chrome stable layer"
    shift
    ;;
  --firefox-version=*)
    FIREFOX_TEMP="${1//--firefox-version=/}"
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
    FREETDS_VERSION="${1//--freetds-version=/}"
    echo "- layer with FreeTDS ${FREETDS_VERSION}"
    shift
    ;;
  --custom-repo=*)
    CUSTOM_REPO="${1//--custom-repo=/}"
    echo "- custom docker repository: ${CUSTOM_REPO}"
    shift
    ;;
  --tag-prefix=*)
    SET_TAG_PREFIX="${1//--tag-prefix=/}"

    echo "- Custom tag prefix: ${SET_TAG_PREFIX}"
    shift
    ;;
  --push-to-hub)
    PUSH_TO_HUB=1
    echo "- Pushing all built layers to docker hub"
    shift
    ;;
  --push-last-as-latest)
    PUSH_LAST_AS_LATEST=1
    PUSH_TO_HUB=1
    echo "- Pushing all built layers to docker hub"
    echo "- pushing last built as latest tag as well"
    shift
    ;;
  *)
    break
    ;;
  esac
done
