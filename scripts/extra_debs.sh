#!/usr/bin/env bash
set -xeuo pipefail

if [ "${1}" == 'skip' ]; then
  exit 0
fi

echo "==============================="
echo "Installing extra debs ${1}     "
echo "==============================="

apt-get update \
  && apt-get install -qqy --no-install-recommends ${1} \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

exit 0
