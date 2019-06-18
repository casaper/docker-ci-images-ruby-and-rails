#!/usr/bin/env bash
set -xeuo pipefail
if [ "${1}" == 'skip' ]; then
  exit 0
fi

echo "==============================="
echo "Installing Firefox ${2}"
echo "==============================="

VERSION=${2}
DOWNLOAD_URL="https://download.mozilla.org/?product=firefox-${VERSION:-latest}&os=linux64&lang=en-US"
GECKO_DRIVER_URL='https://github.com/mozilla/geckodriver/releases/download/v0.22.0/geckodriver-v0.22.0-linux64.tar.gz'
# install FF dependencies
apt-get update \
  && apt-get install -y -q --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        firefox-esr \
  && apt-get -qqy purge firefox-esr \
  && curl -sSL "$DOWNLOAD_URL" | tar xj -C /opt/ \
  && ln -s /opt/firefox/firefox /usr/local/bin/ \
  && curl -sSL "$GECKO_DRIVER_URL" | tar xz -C /usr/local/bin/  \
  && chmod +x /usr/local/bin/geckodriver \
  && echo "FIREFOX_BROWSER_INFO=$(firefox --version)" >> /image_info.txt

exit 0
