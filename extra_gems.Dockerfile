# base image
#
# image tag for the image this one is based on
ARG base_image
FROM $base_image

# extra_debs - install a list of extra specific debian apt packages
#
# space separated package list: eg. imagemagick ghostscript
# default is skip - it installs nothing
ARG extra_gems=skip

LABEL extra_gems=$extra_gems
LABEL base=$base_image
LABEL architecture="x86_64"
LABEL vendor="Panter AG"

RUN gem install ${extra_gems}
