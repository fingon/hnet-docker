# -*- docker-image-name: "d-hnet" -*-
# $Id: Dockerfile $
#
# Author: Markus Stenberg <mstenber@cisco.com>
#
# Copyright (c) 2014 cisco Systems, Inc.
#
# Created:       Thu Mar 13 11:51:22 2014 mstenber
# Last modified: Mon Mar 17 13:53:46 2014 mstenber
# Edit time:     15 min
#


FROM d-base
MAINTAINER "Markus Stenberg <fingon@iki.fi>"
RUN apt-get install -y make sudo git
RUN /usr/local/with-proxy.sh git clone http://github.com/fingon/hnet.git
RUN cd hnet && make setup-debianish
