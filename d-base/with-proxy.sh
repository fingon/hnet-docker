#!/bin/bash -ue
#-*-sh-*-
#
# $Id: with-proxy.sh $
#
# Author: Markus Stenberg <mstenber@cisco.com>
#
# Copyright (c) 2014 cisco Systems, Inc.
#
# Created:       Thu Mar 13 13:53:17 2014 mstenber
# Last modified: Mon Mar 17 13:33:39 2014 mstenber
# Edit time:     11 min
#

# Determine http proxy to use, if any
PROXY=`/usr/local/detect-http-proxy.sh`
[ -z $PROXY ] && exec $*
http_proxy=$PROXY $*

