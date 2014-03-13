# -*- docker-image-name: "d-hnet-netkit-env" -*-
# $Id: Dockerfile $
#
# Author: Markus Stenberg <mstenber@cisco.com>
#
# Copyright (c) 2014 cisco Systems, Inc.
#
# Created:       Thu Mar 13 12:30:43 2014 mstenber
# Last modified: Thu Mar 13 14:11:27 2014 mstenber
# Edit time:     19 min
#


FROM d-hnet-dev
MAINTAINER "Markus Stenberg <fingon@iki.fi>"
RUN cd hnet && perl -i.bak -pe 's/git:/http:/g' .gitmodules 
RUN cd hnet && git submodule update --init netkit
RUN cd hnet/netkit && git submodule update --init kernel

# Losetup can't work inside unprivileged Docker; assume it's available
# from host side
#RUN cd hnet/netkit && git submodule update --init fs
#RUN cd hnet/netkit/fs && make filesystem

# Ideally we'd copy it locally; however, we probably cannot..
#ADD ../../hnet/netkit/kernel/linux-3.10.28.tar.xz /hnet/netkit/kernel
RUN cd hnet/netkit/kernel && /usr/local/with-proxy.sh make pull 2>/dev/null
RUN cd hnet/netkit/kernel && make -j 9 kernel
