# base image
#
# image tag for the image this one is based on
ARG base_image
FROM $base_image

# ci_node_version - Node Version
#
# Can be any of: https://github.com/nodesource/distributions/tree/master/deb
# most commonly one of:  10, 9, 8
# default 10
ARG ci_node_version=10

LABEL node_version=$ci_node_version
LABEL base=$base_image
LABEL architecture="x86_64"
LABEL vendor="Panter AG"

# script for installing firefox and/or google chrome
ADD ./scripts /scripts

RUN /scripts/install_node.sh "${ci_node_version}" \
      # some clean up before finishing this layer
      && rm -rf /var/lib/apt/lists/* \
      && apt-get clean
