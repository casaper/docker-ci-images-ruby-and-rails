#!/usr/bin/env bash

# output colours
DARKGRAY='\033[1;30m'
RED='\033[0;31m'
LIGHTRED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
LIGHTPURPLE='\033[1;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
SET='\033[0m'

function num_of_chars() {
  echo -e -n "$1" | wc -c
}

function indent_left() {
  OPTION_LENGTH=$(num_of_chars "$1")
  INDENT_LENGTH=$(num_of_chars "$2")
  SPACES=$(("$INDENT_LENGTH" - "$OPTION_LENGTH"))
  if (("$SPACES" > 0)); then
    INDENT_OUT=''
    for ((i = 0; i < "$SPACES"; i++)); do
      INDENT_OUT="${INDENT_OUT} "
    done
    echo "$INDENT_OUT"
  else
    echo ' '
  fi
}

function display_help_option() {
  HELP_INDENT="$1"
  TEXT="$2"
  OPTION="--$3"
  HAS_VALUE="$4"
  OPTION_VALUE="$5"
  LEFT_INDENT="$(indent_left "${OPTION}${HAS_VALUE}${OPTION_VALUE}" "$HELP_INDENT")"
  OPTION_STRING="${YELLOW}${OPTION}${SET}${HAS_VALUE}${BOLD}${OPTION_VALUE}${SET}"
  echo -e "${OPTION_STRING}${LEFT_INDENT}${TEXT}"$'\n'
}

function push_to_docker_hub() {
  echo "Pushing image '${1}' to docker repository"
  docker push "$1"
}

function docker_build_with_args() {
  BUILD_ARGS=''
  ARGS=''
  while test $# -gt 0; do
    case "$1" in
    -f | --file)
      DOCKERFILE="$2"
      shift
      shift
      ;;
    -t | --tag)
      TAG="$2"
      shift
      shift
      ;;
    *)
      BUILD_ARGS="${BUILD_ARGS} ${1}"
      shift
      ;;
    esac
  done
  for arg in $BUILD_ARGS; do
    ARGS="${ARGS} --build-arg ${arg}"
  done
  echo "build args: $ARGS"

  TAG="${TAG:-no-tag-given}"
  DOCKERFILE="${DOCKERFILE:-Dockerfile}"
  docker build -t "$TAG" $ARGS -f "$DOCKERFILE" .
}
