#!/bin/bash -ue
#-*-sh-*-
#
# $Id: detect-http-proxy.sh $
#
# Author: Markus Stenberg <mstenber@cisco.com>
#
# Copyright (c) 2014 cisco Systems, Inc.
#
# Created:       Mon Mar 17 13:15:29 2014 mstenber
# Last modified: Mon Mar 17 13:52:15 2014 mstenber
# Edit time:     5 min
#


# Set up the variables and call subprocess with appropriately set HTTP_PROXY
PROXY_PORT=8000
GW=`ip route | egrep '^default ' | cut -d ' ' -f 3`

# No gw -> bypass mode
[ -z $GW ] && exit 0

# Assumption: 'nc' is available; prefer traditional but non-traditional ok too
NC=`[ -f /bin/nc.traditional ] && echo nc.traditional || echo nc`
$NC -z $GW $PROXY_PORT || exit 0

# yay, found a proxy
echo http://$GW:$PROXY_PORT 

