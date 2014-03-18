#!/bin/bash -ue
#-*-sh-*-
#
# $Id: run.sh $
#
# Author: Markus Stenberg <mstenber@cisco.com>
#
# Copyright (c) 2014 cisco Systems, Inc.
#
# Created:       Tue Mar 18 11:30:44 2014 mstenber
# Last modified: Tue Mar 18 11:34:11 2014 mstenber
# Edit time:     3 min
#

NAME=$1
shift
PASS=$1
shift
[ -n "$PASS" ] || exit 1

cd /bbs
buildslave create-slave slave $MASTER_PORT_9989_TCP_ADDR:$MASTER_PORT_9989_TCP_PORT $NAME $PASS
cd slave && twistd --nodaemon --no_save -y ./buildbot.tac
