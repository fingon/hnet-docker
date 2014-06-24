DEBIAN_MIRROR=http://ftp.fi.debian.org/debian
MKIMAGE_DEBOOTSTRAP=/usr/share/docker.io/contrib/mkimage-debootstrap.sh
# Note: If this script isn't available (it's part of docker.io contrib),
# set the variable empty and get debian32 in some other way..

DOCKERSUBDIRS=\
  d-base d-hnet d-hnet-netkit \
  d32-base d32-hnet d32-hnet-netkit \
  t-base t-hnet t-hnet-netkit \
  u-base u-hnet u-hnet-netkit \
  buildbot-master d-bb d32-bb t-bb u-bb

# u-base is as-is (too much diff to d-base).
# u-hnet and u-hnet-netkit are created as copies of d-hnet*, and then modified
MADESUBDIRS=\
  d32-hnet d32-hnet-netkit d32-bb \
  t-hnet t-hnet-netkit t-bb \
  u-hnet u-hnet-netkit u-bb

all: $(DOCKERSUBDIRS:%=%.docker)

## Buildbot targets

BUILDSLAVES=d-bb d32-bb t-bb u-bb
# omit Ubuntu until new LTS is available; 12.04 doesn't have recent cmake

.PHONY: start
start: rm-exited bb-master.start $(BUILDSLAVES:%=%-slave.start)

.PHONY: stop
stop: bb-master.stop $(BUILDSLAVES:%=%-slave.stop)

.PHONY: kill
kill: bb-master.kill $(BUILDSLAVES:%=%-slave.kill)

# Fake docker creation
debian32.docker: $(MKIMAGE_DEBOOTSTRAP)
	docker images | grep -q '^debian32' || \
		$(MKIMAGE_DEBOOTSTRAP) -a i386 debian32 wheezy $(DEBIAN_MIRROR)


# master
bb-master.start: buildbot-master.docker
	sleep 1 # stupid race condition in Docker 0.11.0 at least
	./ensure-started.sh bb-master || \
          docker run --name bb-master -d -p 8010:8010 -v $(HOME)/hnet:/host-hnet:ro buildbot-master

bb-master.shell: buildbot-master.docker
	sleep 1 # stupid race condition in Docker 0.11.0 at least
	docker run --name bb-master -p 8010:8010 -v $(HOME)/hnet:/host-hnet:ro -i -t buildbot-master /bin/bash

# slaves
%-slave.start: %.docker bb-master.start
	sleep 1 # stupid race condition in Docker 0.11.0 at least
	./ensure-started.sh $*-slave || \
          (docker rm $*-slave ; docker run --name $*-slave --link bb-master:master -d -v $(HOME)/hnet:/host-hnet:ro $* )

# Netkit utilities

dsh: d-hnet-netkit.docker
	sleep 1 # stupid race condition in Docker 0.11.0 at least
	docker run --privileged -v $(HOME)/hnet/netkit/fs:/hnet/netkit/fs:ro -i -t d-hnet-netkit /bin/bash

ush: u-hnet-netkit.docker
	sleep 1 # stupid race condition in Docker 0.11.0 at least
	docker run --privileged -v $(HOME)/hnet/netkit/fs:/hnet/netkit/fs:ro -i -t u-hnet-netkit /bin/bash

.PHONY: clean
clean:    kill rm-exited $(DOCKERSUBDIRS:%=%.clean) uclean rmi-none

rm-exited:
	docker rm `docker ps -a | grep Exit | cut -d ' ' -f 1` 2>/dev/null || true

rmi-none:
	docker rmi `docker images | grep '<none>' | perl -pe 's/\s+/ /g' | cut -d ' ' -f 3` 2>/dev/null || true

# Debian 32 target (Debian stable, but with 32-bit userland)

d32-base.docker: d32-base-rsync debian32.docker

d32-base-rsync:
	rsync -a $(wildcard d-base/*.sh) d32-base

d32-hnet/Dockerfile: d-hnet/Dockerfile
	mkdir d32-hnet
	perl -pe 's/d-base/d32-base/g' < d-hnet/Dockerfile | \
	perl -pe 's/d-hnet/d32-hnet/g' > d32-hnet/Dockerfile

d32-bb/Dockerfile: d-bb/Dockerfile
	mkdir d32-bb
	perl -pe 's/d-hnet-netkit/d32-hnet/g' < d-bb/Dockerfile | \
	perl -pe 's/debian/debian32/g' | \
	perl -pe 's/d-bb/d32-bb/g' \
		> d32-bb/Dockerfile
	cp $(wildcard d-bb/*.sh) d32-bb
	cp $(wildcard d-bb/*.py) d32-bb

d32-hnet-netkit/Dockerfile: d-hnet-netkit/Dockerfile
	mkdir d32-hnet-netkit
	perl -pe 's/d-hnet/d32-hnet/g' < d-hnet-netkit/Dockerfile > d32-hnet-netkit/Dockerfile
	cp $(wildcard d-hnet-netkit/*.sh) d32-hnet-netkit

# Testing target (derived from Debian, but not quite the same)

t-base.docker: t-base-rsync

t-base-rsync:
	rsync -a $(wildcard d-base/*.sh) t-base

t-hnet/Dockerfile: d-hnet/Dockerfile
	mkdir t-hnet
	perl -pe 's/d-base/t-base/g' < d-hnet/Dockerfile | \
	perl -pe 's/d-hnet/t-hnet/g' > t-hnet/Dockerfile

t-bb/Dockerfile: d-bb/Dockerfile
	mkdir t-bb
	perl -pe 's/d-hnet-netkit/t-hnet/g' < d-bb/Dockerfile | \
	perl -pe 's/debian/testing/g' | \
	perl -pe 's/d-bb/t-bb/g' \
		> t-bb/Dockerfile
	cp $(wildcard d-bb/*.sh) t-bb
	cp $(wildcard d-bb/*.py) t-bb

t-hnet-netkit/Dockerfile: d-hnet-netkit/Dockerfile
	mkdir t-hnet-netkit
	perl -pe 's/d-hnet/t-hnet/g' < d-hnet-netkit/Dockerfile > t-hnet-netkit/Dockerfile
	cp $(wildcard d-hnet-netkit/*.sh) t-hnet-netkit


# Ubuntu target (derived from Debian, but not quite the same)

u-base.docker: u-base-rsync

u-base-rsync:
	rsync -a $(wildcard d-base/*.sh) u-base

u-hnet/Dockerfile: d-hnet/Dockerfile
	mkdir u-hnet
	perl -pe 's/d-base/u-base/g' < d-hnet/Dockerfile | \
	perl -pe 's/d-hnet/u-hnet/g' > u-hnet/Dockerfile

u-bb/Dockerfile: d-bb/Dockerfile
	mkdir u-bb
	perl -pe 's/d-hnet-netkit/u-hnet/g' < d-bb/Dockerfile | \
	perl -pe 's/debian/ubuntu/g' | \
	perl -pe 's/d-bb/u-bb/g' \
		> u-bb/Dockerfile
	cp $(wildcard d-bb/*.sh) u-bb
	cp $(wildcard d-bb/*.py) u-bb

u-hnet-netkit/Dockerfile: d-hnet-netkit/Dockerfile
	mkdir u-hnet-netkit
	perl -pe 's/d-hnet/u-hnet/g' < d-hnet-netkit/Dockerfile > u-hnet-netkit/Dockerfile
	cp $(wildcard d-hnet-netkit/*.sh) u-hnet-netkit

# General pattern rules

%.docker: %/Dockerfile
	cd $* && docker build -t $* .

%.shell: %.docker
	sleep 1 # stupid race condition in Docker 0.11.0 at least
	docker run -i -v $(HOME):/hosthome:ro -t $* /bin/bash

%.stop:
	-docker stop $*

%.kill:
	-docker kill $*

uclean:
	rm -rf $(MADESUBDIRS)

%.clean: rm-exited
	-docker rmi $*

# Manual dependencies (so we can use make -j N)

buildbot-master.docker: d-base.docker

d-hnet.docker: d-base.docker
d-hnet-netkit.docker: d-hnet.docker
d-bb.docker: d-hnet-netkit.docker

d32-hnet.docker: d32-base.docker d32-hnet/Dockerfile
d32-hnet-netkit.docker: d32-hnet.docker d32-hnet-netkit/Dockerfile
d32-bb.docker: d32-hnet.docker d32-bb/Dockerfile

t-hnet.docker: t-base.docker t-hnet/Dockerfile
t-hnet-netkit.docker: t-hnet.docker t-hnet-netkit/Dockerfile
t-bb.docker: t-hnet.docker t-bb/Dockerfile

u-hnet.docker: u-base.docker u-hnet/Dockerfile
u-hnet-netkit.docker: u-hnet.docker u-hnet-netkit/Dockerfile
u-bb.docker: u-hnet.docker u-bb/Dockerfile
