#!/bin/bash -ue
#-*-sh-*-
#
# $Id: setup-proxy.sh $
#
# Author: Markus Stenberg <mstenber@cisco.com>
#
# Copyright (c) 2014 cisco Systems, Inc.
#
# Created:       Thu Mar 13 11:37:51 2014 mstenber
# Last modified: Thu Mar 13 15:27:28 2014 mstenber
# Edit time:     3 min
#

DEBIAN_MIRROR="ftp\\.fi\\.debian\\.org"
perl -i.bak -pe "s/http\.debian\.net/$DEBIAN_MIRROR/g" /etc/apt/sources.list
GW=`ip route | egrep '^default ' | cut -d ' ' -f 3`
if [ -n $GW ]
then
    echo "Acquire::http::Proxy \"http://\"$GW\":8000\";" > /etc/apt/apt.conf.d/30proxy
    apt-get update
fi
apt-get -y install git
[ -n $GW ] && git config --global http.proxy http://$GW:8000
