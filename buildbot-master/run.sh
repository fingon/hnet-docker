#!/bin/bash -ue
#-*-sh-*-
#
# $Id: run.sh $
#
# Author: Markus Stenberg <mstenber@cisco.com>
#
# Copyright (c) 2014 cisco Systems, Inc.
#
# Created:       Mon Mar 17 15:34:49 2014 mstenber
# Last modified: Mon Mar 17 15:43:10 2014 mstenber
# Edit time:     0 min
#

cd /bb && twistd --nodaemon --no_save -y ./buildbot.tac

