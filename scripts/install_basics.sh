#!/usr/bin/env bash
set -xeuo pipefail

apt-get update \
      && apt-get install -y -q --no-install-recommends \
        libssl-dev \
        build-essential \
        git

if [ "$1" == 'skip' ]; then
  gem install bundler
else
  gem install bundler --version "${1}"
fi

exit 0
