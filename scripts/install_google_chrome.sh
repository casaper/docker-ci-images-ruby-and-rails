#!/usr/bin/env bash
set -xeuo pipefail

if [ "${1}" == 'skip' ]; then
  exit 0
fi

echo "==============================="
echo "Installing chrome     "
echo "==============================="

apt-get update &&
  apt-get -qqy --no-install-recommends install \
    apt-transport-https \
    ca-certificates \
    gnupg \
    curl \
    fontconfig &&
  curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - &&
  echo 'deb https://dl.google.com/linux/chrome/deb/ stable main' >/etc/apt/sources.list.d/google-chrome.list &&
  apt-get update &&
  apt-get -qqy --no-install-recommends install google-chrome-stable &&
  echo "CHROME_BROWSER_INFO=$(google-chrome --version)" >>/image_info.txt

exit 0
