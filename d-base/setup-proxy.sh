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
# Last modified: Mon Mar 17 13:42:03 2014 mstenber
# Edit time:     13 min
#

# Fix Debian mirror (on Debian only, no harm on Ubuntu as no match..)
DEBIAN_MIRROR="ftp\\.fi\\.debian\\.org"
perl -i.bak -pe "s/http\.debian\.net/$DEBIAN_MIRROR/g" /etc/apt/sources.list

# Some ideas acquired from 
#http://askubuntu.com/questions/53443/how-do-i-ignore-a-proxy-if-not-available

echo 'Acquire::http::ProxyAutoDetect "/usr/local/detect-http-proxy.sh";' > /etc/apt/apt.conf.d/30proxy
apt-get update

