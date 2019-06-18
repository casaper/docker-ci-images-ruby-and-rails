# base image
#
# image tag for the image this one is based on
ARG base_image
FROM $base_image

# extra_debs - install a list of extra specific debian apt packages
#
# space separated package list: eg. imagemagick ghostscript
# default is skip - it installs nothing
ARG extra_debs=skip

LABEL extra_debs=$extra_debs
LABEL base=$base_image
LABEL architecture="x86_64"
LABEL vendor="Panter AG"

# script for installing firefox and/or google chrome
ADD ./scripts /scripts

RUN /scripts/extra_debs.sh "${extra_debs}" \
      # some clean up before finishing this layer
      && rm -rf /var/lib/apt/lists/* \
      && apt-get clean
