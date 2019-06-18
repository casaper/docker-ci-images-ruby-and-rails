# base image
#
# image tag for the image this one is based on
ARG base_image
FROM $base_image

LABEL browser="google-chrome-stable"
LABEL base=$base_image
LABEL architecture="x86_64"
LABEL vendor="Panter AG"

# script for installing firefox and/or google chrome
ADD ./scripts /scripts

RUN /scripts/install_google_chrome.sh "install" \
      # some clean up before finishing this layer
      && rm -rf /var/lib/apt/lists/* \
      && apt-get clean
