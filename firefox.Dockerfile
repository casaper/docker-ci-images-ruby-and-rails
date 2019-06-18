# base image
#
# image tag for the image this one is based on
ARG base_image
FROM $base_image

# firefox version
#
# One of: latest, beta-latest, esr-latest
# or specific from http://releases.mozilla.org/pub/firefox/releases/
ARG firefox_version=latest

LABEL browser="firefox"
LABEL browser_version=$firefox_version
LABEL base=$base_image
LABEL architecture="x86_64"
LABEL vendor="Panter AG"

# script for installing firefox and/or google chrome
ADD ./scripts /scripts

RUN /scripts/install_firefox.sh "install" "$firefox_version" \
      # some clean up before finishing this layer
      && rm -rf /var/lib/apt/lists/* \
      && apt-get clean
