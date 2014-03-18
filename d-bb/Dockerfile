# -*- docker-image-name: "d-bb" -*-
# $Id: Dockerfile $
#
# Author: Markus Stenberg <mstenber@cisco.com>
#
# Copyright (c) 2014 cisco Systems, Inc.
#
# Created:       Tue Mar 18 11:23:12 2014 mstenber
# Last modified: Tue Mar 18 12:15:01 2014 mstenber
# Edit time:     2 min
#


# Might at some point want to run tests; distant future though, so
# ignoring for now..
#FROM d-hnet-netkit

FROM d-hnet
MAINTAINER "Markus Stenberg <fingon@iki.fi>"
RUN apt-get -y install buildbot-slave
RUN mkdir /bbs
ADD . /bbs
CMD /bbs/run.sh debian pass

