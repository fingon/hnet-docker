#!/bin/bash -ue
#-*-sh-*-
#
# $Id: ensure-started.sh $
#
# Author: Markus Stenberg <mstenber@cisco.com>
#
# Copyright (c) 2014 cisco Systems, Inc.
#
# Created:       Tue Mar 18 11:15:47 2014 mstenber
# Last modified: Tue Mar 18 11:39:11 2014 mstenber
# Edit time:     3 min
#

# This utility script ensures that particular docker container is running.
NAME=$1
[ -n "$NAME" ] || exit 1

RUNNING=`docker ps | grep "$NAME"`
[ -n "$RUNNING" ] && exit 0

exec docker start $NAME

