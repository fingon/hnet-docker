## -*- docker-image-name: "d-dev" -*-
FROM debian
MAINTAINER "Markus Stenberg <fingon@iki.fi>"
RUN mkdir -p /usr/local
ADD . /usr/local/
RUN sh /usr/local/setup-proxy.sh
# Setup-proxy implies also apt-get update

# Upgrade to the latest, just in case the upstream image is bit old
RUN apt-get -y dist-upgrade
