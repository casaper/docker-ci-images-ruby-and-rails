#!/usr/bin/env bash
set -xeuo pipefail

if [ "${1}" == 'skip' ]; then
  exit 0
fi

echo "==============================="
echo " Installing FreeTDS ${1}"
echo "==============================="

apt-get update \
  && apt-get install -y -q --no-install-recommends \
        curl \
        build-essential \
        libc6-dev \
  && curl -sL "ftp://ftp.freetds.org/pub/freetds/stable/freetds-${1}.tar.gz" > "freetds-${1}.tar.gz" \
  && tar -xzf "freetds-${1}.tar.gz" \
  && cd "freetds-${1}" \
  && ./configure --prefix=/usr/local --with-tdsver=7.3 \
  && make \
  && make install \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

exit 0
