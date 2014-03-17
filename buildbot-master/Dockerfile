# -*- docker-image-name: "buildbot-master" -*-
# $Id: Dockerfile $
#
# Author: Markus Stenberg <mstenber@cisco.com>
#
# Copyright (c) 2014 cisco Systems, Inc.
#
# Created:       Mon Mar 17 15:10:35 2014 mstenber
# Last modified: Mon Mar 17 15:45:49 2014 mstenber
# Edit time:     16 min
#


FROM d-base
MAINTAINER "Markus Stenberg <fingon@iki.fi>"
RUN apt-get -y install buildbot
RUN buildbot create-master bb
ADD master.cfg /bb/master.cfg
ADD run.sh /bb/run.sh
EXPOSE 8010
ENTRYPOINT /bb/run.sh
VOLUMES ["/host-hnet"]


