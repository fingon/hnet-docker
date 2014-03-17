# -*- docker-image-name: "d-hnet-netkit" -*-
# $Id: Dockerfile $
#
# Author: Markus Stenberg <mstenber@cisco.com>
#
# Copyright (c) 2014 cisco Systems, Inc.
#
# Created:       Thu Mar 13 12:30:43 2014 mstenber
# Last modified: Mon Mar 17 13:42:54 2014 mstenber
# Edit time:     36 min
#


FROM d-hnet
MAINTAINER "Markus Stenberg <fingon@iki.fi>"

RUN cd hnet && perl -i.bak -pe 's/git:/http:/g' .gitmodules 
RUN cd hnet && /usr/local/with-proxy.sh git submodule update --init netkit

# SHOULD build filesystem; but cannot ..
# Losetup can't work inside unprivileged Docker; assume it's available
# from host side
#RUN cd hnet/netkit && git submodule update --init fs
#RUN cd hnet/netkit/fs && make filesystem

# Build kernel
# Ideally we'd copy it locally; however, we probably cannot..
#ADD ../../hnet/netkit/kernel/linux-3.10.28.tar.xz /hnet/netkit/kernel
RUN cd hnet/netkit && /usr/local/with-proxy.sh git submodule update --init kernel
RUN cd hnet/netkit/kernel && /usr/local/with-proxy.sh make pull 2>/dev/null
RUN cd hnet/netkit/kernel && make -j 9 kernel

# We also build UML utilities
RUN cd hnet/netkit && /usr/local/with-proxy.sh git submodule update --init uml-utilities
RUN cd hnet/netkit && make -j 9 uml-utilities.build

# This should be sourced 'somewhere' with built filesystem
VOLUME ["/hnet/netkit/fs"]

ADD fix-netkit.sh /usr/local/
RUN echo . /usr/local/fix-netkit.sh >> /etc/bash.bashrc

# When playing with netkit, ifconfig is nice to have
RUN apt-get install -q net-tools



