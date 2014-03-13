#!/bin/bash -ue
#-*-sh-*-
#
# $Id: fix-netkit.sh $
#
# Author: Markus Stenberg <mstenber@cisco.com>
#
# Copyright (c) 2014 cisco Systems, Inc.
#
# Created:       Thu Mar 13 14:55:07 2014 mstenber
# Last modified: Thu Mar 13 15:06:34 2014 mstenber
# Edit time:     4 min
#

# Gnnh.
umount /dev/shm
mount shm /dev/shm -t tmpfs -o rw

export NETKIT_HOME=/hnet/netkit
export PATH=$PATH:/hnet/netkit/bin

# Fix tunnel devices
[ -d /dev/net ] || mkdir -p /dev/net
[ -c /dev/net/tun ] || mknod /dev/net/tun c 10 200
