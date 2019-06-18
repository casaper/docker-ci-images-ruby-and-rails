#!/usr/bin/env bash
set -xeuo pipefail

if [ "${1}" == 'skip' ]; then
  exit 0
fi
echo "==============================="
echo "Installing Node in version ${1}"
echo "==============================="

apt-get update \
  && apt-get install -y -q --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
  && curl -sL "https://deb.nodesource.com/setup_${1}.x" | bash - \
  && apt-get install nodejs -yqq \
  && npm i -g yarn \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

exit 0
