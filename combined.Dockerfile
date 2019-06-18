# ruby_version - Ruby Version
#
# Can by any plain version tag listed in: https://hub.docker.com/r/library/ruby/tags/
# No slim, alpine, jessie or stretch tho. Just plain number tags.
ARG ruby_version=2.5.1
FROM ruby:$ruby_version

# firefox - Install headless firefox
#
# install: installs
# anything else: firefox won't be installed
ARG firefox=skip

# One of: latest, beta-latest, esr-latest or specific from http://releases.mozilla.org/pub/firefox/releases/
ARG firefox_version=latest

# chrome - Install headless chrome
#
# install: installs
# anything else: chrome won't be installed
ARG google_chrome=skip

# extra_debs - install a list of extra specific debian apt packages
#
# space separated package list: eg. imagemagick ghostscript
# default is none
ARG extra_debs=skip

# bundler_version - set specific bundler version to install
#
# provide bundler version installs it
# skip: will install latest bundler version available
ARG bundler_version=skip

# ci_node_version - Node Version
#
# Can be any of: https://github.com/nodesource/distributions/tree/master/deb
# most commonly one of:  10, 9, 8
ARG ci_node_version=skip

LABEL version=$ruby_version
LABEL architecture="x86_64"
LABEL vendor="Panter AG"

# script for installing firefox and/or google chrome
ADD ./scripts /scripts

RUN /scripts/install_basics.sh "${bundler_version}" \
      # install node if version passed
      && /scripts/install_node.sh "${ci_node_version}" \

      # Install extra deps if any
      && /scripts/extra_debs.sh "${extra_debs}" \

      # Firefox
      && /scripts/install_firefox.sh "$firefox" "$firefox_version" \

      # chrome
      && /scripts/install_google_chrome.sh "$google_chrome" \

      # some clean up before finishing this layer
      && rm -rf /var/lib/apt/lists/* \
      && apt-get clean
