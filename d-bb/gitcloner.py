#!/usr/bin/env python
# -*- coding: utf-8 -*-
# -*- Python -*-
#
# $Id: gitcloner.py $
#
# Author: Markus Stenberg <markus.stenberg@iki.fi>
#
# Created:       Tue Apr  9 14:49:22 2013 mstenber
# Last modified: Tue Apr  9 15:56:53 2013 mstenber
# Edit time:     28 min
#
"""

This is a minimalist utility script, which using git clone clones a
repository with submodules to local directory, while using trickery
(http://stackoverflow.com/questions/9932275/how-can-i-get-git-clone-recursive-a-b-to-use-the-the-submodule-repositories-in) to rewrite initial .gitmodules to use the local copy exclusively.

Pro: Allows for rapid copying of Git repositories with (potentially N
levels of) nested submodules.

Cons: Not as elegant as raw git. Oh well, as they say.

"""

import re
submodule_re = re.compile('^\[submodule "(.*)"\]$').match

import os
import os.path

def shell(s):
    print '#', s
    r = os.system(s)
    assert not r, 'got return value %s' % r


# Take a look at directory. If it contains .gitmodules
# - rewrite it,
# - do git submodule update --init there, and
# - checkout old .gitmodules
def recursively_update(rpath, lpath, basepath):
    n = os.path.basename(lpath)
    if n == '.git':
        return
    apath = os.path.join(lpath, '.gitmodules')
    if os.path.isfile(apath):
        napath = apath + ".new"
        f = open(napath, 'w')
        for line in open(apath):
            m = submodule_re(line)
            if m is not None:
                sn = m.group(1)
                url = os.path.join(rpath, basepath, sn)
                f.write("""
[submodule "%(sn)s"]
\tpath = %(sn)s
\turl = %(url)s
""" % locals())
        f.close()
        del f
        os.rename(napath, apath)
        shell('(cd %s && git submodule init)' % lpath)
        shell('(cd %s && git submodule update )' % lpath)
        shell('(cd %s && git checkout .gitmodules)' % lpath)
        shell('(cd %s && git submodule sync)' % lpath)
    else:
        #print 'ignoring', lpath
        pass
    # Then, recurse to subdirectories
    files = os.listdir(lpath)
    for n2 in files:
        lpath2 = os.path.join(lpath, n2)
        if os.path.isdir(lpath2):
            recursively_update(rpath, lpath2, os.path.join(basepath, n2))


def clone(rpath):
    lpath = os.path.basename(rpath)
    shell('git clone %s' % rpath)
    recursively_update(rpath, lpath, '')

if __name__ == '__main__':
    import sys
    (repo,) = sys.argv[1:] # exactly 1 argument supported
    clone(repo)
