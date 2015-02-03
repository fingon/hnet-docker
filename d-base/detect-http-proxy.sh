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
# Last modified: Tue Feb  3 14:33:51 2015 mstenber
# Edit time:     7 min
#


# Set up the variables and call subprocess with appropriately set HTTP_PROXY
PROXY_PORT=8000
GW=`ip route | egrep '^default ' | cut -d ' ' -f 3`

# No gw -> bypass mode
[ -z $GW ] && exit 0

# Assumption: 'nc' is available; prefer traditional but non-traditional ok too
if [ -x /bin/nc.traditional ]
then
     /bin/nc.traditional -z $GW $PROXY_PORT || exit 0
elif [ -x /bin/nc ]
then
     /bin/nc -z $GW $PROXY_PORT || exit 0
else
    exit 0
fi

# yay, found a proxy
echo http://$GW:$PROXY_PORT 

