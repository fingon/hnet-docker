## -*- docker-image-name: "d-base" -*-
FROM debian:stable
MAINTAINER "Markus Stenberg <fingon@iki.fi>"
RUN apt-get -y install netcat-traditional
RUN mkdir -p /usr/local
ADD . /usr/local/
RUN sh /usr/local/setup-proxy.sh
# Setup-proxy implies also apt-get update

# Upgrade to the latest, just in case the upstream image is bit old
RUN apt-get -y dist-upgrade
