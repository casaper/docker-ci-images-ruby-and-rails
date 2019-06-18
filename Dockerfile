###########################################
##  Main Ruby layer others are based on  ##
###########################################

# there needs to be a base ruby layer built first for every ruby version before
# browser or node layers that depend upon it are built

# ruby_version - Ruby Version
#
# Can by any plain version tag listed in: https://hub.docker.com/r/library/ruby/tags/
# No slim, alpine, jessie or stretch tho. Just plain number tags.
ARG ruby_version=2.5.1
FROM ruby:$ruby_version

# bundler_version - set specific bundler version to install
#
# provide bundler version installs it
# skip: will install latest bundler version available
ARG bundler_version=skip

ADD ./scripts /scripts

RUN /scripts/install_basics.sh "${bundler_version}" \
      # create cache dir
      && mkdir /cache \
      && chmod a+rwx /cache \
      # some clean up before finishing this layer
      && rm -rf /var/lib/apt/lists/* \
      && apt-get clean
