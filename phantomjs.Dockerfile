# base image
#
# image tag for the image this one is based on
ARG base_image
FROM $base_image

LABEL browser="phantomjs"
LABEL base=$base_image
LABEL architecture="x86_64"
LABEL vendor="Panter AG"

COPY ./scripts/run_phantomjs.sh /usr/local/bin/phantomjs

RUN apt-get update \
      && apt-get install -y --no-install-recommends \
      ca-certificates \
      bzip2 \
      libfontconfig1 \
      libfontconfig1-dev \
      libfreetype6 \
      libfreetype6-dev \
      libssl-dev \
      openssl \
      curl \
      && mkdir /tmp/phantomjs \
      && curl -L https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
      | tar -xj --strip-components=1 -C /tmp/phantomjs \
      && cd /tmp/phantomjs \
      && mv bin/phantomjs /usr/local/bin/phantomjs-bin \
      && chmod a+x /usr/local/bin/phantomjs \
      && apt-get clean \
      && rm -rf /tmp/* /var/lib/apt/lists/*

