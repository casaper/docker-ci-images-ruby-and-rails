# base image
#
# image tag for the image this one is based on
ARG base_image
FROM $base_image

# ghostscript_version - set specific ghostscripts version to install
#
# default 9.25
ARG ghostscript_version=9.25

RUN apt-get update \
      # Install initially needed tools for setup
      && apt-get install -y -q --no-install-recommends \
        # some gems will fail to bundle unless this is present
        libssl-dev \
        build-essential \
        git \
  && apt-cache policy ghostscript \
  && apt-get update \
  && apt-get install ghostscript=9.25 -qy \
  # clean up
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean
