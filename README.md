# Docker Images for CI with Rails

[Docker Hub](https://hub.docker.com/r/casaper/docker-ci-images-ruby-and-rails-repo):  
https://hub.docker.com/r/casaper/docker-ci-images-ruby-and-rails-repo

## The idea behind building with layers and pushing them as separate tags

This is meant for you to be able to selectively use or not use higher layers. For example, it enables you to use
the same image for production deployments and for CI, but on the production deployment you skip stuff on higher
layers you don't want to have there. 

For example:

- For the CI: casaper/docker-ci-images-ruby-and-rails-repo:ruby-2.6.5-node10-chrome
- For production: casaper/docker-ci-images-ruby-and-rails-repo:ruby-2.6.5-node10

This way you won't have the chrome browser on your production instance.  
This renders your image not only a bit smaller, but also reduces the potential performance, stability and even attack vectors such unnecessary packages might bring along.

## Build Layer chain script

The script creates a chain of on top of each other built layers.

```
user@hostname $ ./build_layer_chain.sh --help

build_layer_chain.sh - build a chain of docker image layers for ruby ci

Usage: ./build_layer_chain.sh [options]

options:

--h, --help                  Show this help

--ruby-version=2.6.5         Default is 2.6. See https://hub.docker.com/_/ruby for available base images.

--bundler-version=1.17.3     Install a specific bundler version.
                             See 'tail -n 2 Gemfile.lock' in the project your building your image for.

--node-version=10.x          Build node layer with version - options 8.x, 10.x, 12.x
                             Or any of the ones here: https://j.mp/node-versions. Just exclude 'setup_'
                             Will install yarn for that node version with 'npm install -g yarn'

--chrome                     Build layer with google-chrome-stable

--firefox-version=latest     Build layer with Firefox [latest|beta-latest|esr-latest]
                             Or specific version https://releases.mozilla.org/pub/firefox/releases/

--extra-gems='heroku pry'    Space separated list of gems to pre-install in a docker layer.
                             Could be used for gems you don't have in the projects bundle.

--extra-debs='xy xz'         Space separated list of apt packages.
                             This would do 'apt-get install --no-install-recommends xy xz'
                             By default the whole list of debs you add is added to the image tag:
                             casaper/docker-ci-images-ruby-and-rails-repo:ruby-2.6.5-xy-xz

--push-to-hub                Push all built tags to docker hub
                             See https://hub.docker.com/r/casaper/docker-ci-images-ruby-and-rails-repo

--push-last-as-latest        Push the last built image as well as latest tag.
                             This enables --push-to-hub flag allongside

--custom-repo=abc/xyz        Change the repository to something else:
                             abc/xyz:ruby-2.6.5-node10

--tag-prefix=none            Don't add a tag prefix. Ruby version number will be start of tag:
                             casaper/docker-ci-images-ruby-and-rails-repo:2.6.5-node10

--tag-prefix=custom-         Change default tag prefix "ruby-" to custom string:
                             casaper/docker-ci-images-ruby-and-rails-repo:custom-2.6.5-node10

--extra-debs-tag-extra       No deb list in tag. Add only '-extra' instead
                             Only has an effect in combination with '--extra-debs='.

--freetds-version=1.1.20     Build layer that has freetds of given version.
                             This is needed when the image needs to access a MS-SQLServer.
                             Available versions: ftp://ftp.freetds.org/pub/freetds/stable/

```