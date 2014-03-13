# -*- docker-image-name: "d-hnet-dev" -*-
# $Id: Dockerfile $
#
# Author: Markus Stenberg <mstenber@cisco.com>
#
# Copyright (c) 2014 cisco Systems, Inc.
#
# Created:       Thu Mar 13 11:51:22 2014 mstenber
# Last modified: Thu Mar 13 13:25:33 2014 mstenber
# Edit time:     14 min
#


FROM d-dev
MAINTAINER "Markus Stenberg <fingon@iki.fi>"
RUN apt-get install -y make sudo
RUN git clone http://github.com/fingon/hnet.git
RUN cd hnet && make setup-debianish
