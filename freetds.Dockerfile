# base image
#
# image tag for the image this one is based on
ARG base_image
FROM $base_image

# firefox version
#
# One of: latest, beta-latest, esr-latest
# or specific from http://releases.mozilla.org/pub/firefox/releases/
ARG freetds_version=1.1.2

LABEL base=$base_image
LABEL architecture="x86_64"
LABEL vendor="Panter AG"

# script for installing firefox and/or google chrome
ADD ./scripts /scripts

RUN /scripts/install_freetds.sh "$freetds_version" \
      # some clean up before finishing this layer
      && rm -rf /var/lib/apt/lists/* /scripts \
      && apt-get clean
