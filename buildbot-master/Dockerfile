# -*- docker-image-name: "buildbot-master" -*-
# $Id: Dockerfile $
#
# Author: Markus Stenberg <mstenber@cisco.com>
#
# Copyright (c) 2014 cisco Systems, Inc.
#
# Created:       Mon Mar 17 15:10:35 2014 mstenber
# Last modified: Tue Jun 16 18:15:32 2015 mstenber
# Edit time:     28 min
#


FROM d-base
MAINTAINER "Markus Stenberg <fingon@iki.fi>"

# Use binary (easy path)
RUN apt-get -y install buildbot

# Use not-binary (harder)
#RUN apt-get -y install python-setuptools python-dev
#RUN /usr/local/with-proxy.sh easy_install buildbot

# Use git clone (even more hard?.. ha ha)
#RUN apt-get -y install python-setuptools python-dev python-pip git
#RUN /usr/local/with-proxy.sh git clone https://github.com/buildbot/buildbot.git
#RUN cd buildbot && /usr/local/with-proxy.sh pip install -e master

RUN buildbot create-master bb
ADD master.cfg /bb/master.cfg
ADD run.sh /bb/run.sh
EXPOSE 8010
EXPOSE 9989
VOLUME ["/host-hnet"]
CMD /bb/run.sh


