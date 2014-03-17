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
# Last modified: Thu Mar 13 13:59:00 2014 mstenber
# Edit time:     3 min
#

# Set up the variables and call subprocess with appropriately set HTTP_PROXY
GW=`ip route | egrep '^default ' | cut -d ' ' -f 3`

# No gw -> bypass mode
[ -z $GW ] && exec $* 

# GW -> set up environment variables
http_proxy=http://$GW:8000 $*

