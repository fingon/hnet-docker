DOCKERSUBDIRS=\
  d-base d-hnet d-hnet-netkit \
  t-base t-hnet t-hnet-netkit \
  u-base u-hnet u-hnet-netkit \
  buildbot-master d-bb u-bb

# u-base is as-is (too much diff to d-base).
# u-hnet and u-hnet-netkit are created as copies of d-hnet*, and then modified
MADESUBDIRS=\
  t-hnet t-hnet-netkit t-bb \
  u-hnet u-hnet-netkit u-bb

all: $(DOCKERSUBDIRS:%=%.docker)

## Buildbot targets

BUILDSLAVES=d-bb t-bb u-bb

.PHONY: start
start: rm-exited bb-master.start $(BUILDSLAVES:%=%-slave.start)

.PHONY: stop
stop: bb-master.stop $(BUILDSLAVES:%=%-slave.stop)

.PHONY: kill
kill: bb-master.kill $(BUILDSLAVES:%=%-slave.kill)

# master
bb-master.start: buildbot-master.docker
	./ensure-started.sh bb-master || \
          docker run --name bb-master -d -p 8010:8010 -v $(HOME)/hnet:/host-hnet:ro buildbot-master

bb-master.shell: buildbot-master.docker
	docker run --name bb-master -p 8010:8010 -v $(HOME)/hnet:/host-hnet:ro -i -t buildbot-master /bin/bash

# slaves
%-slave.start: %.docker bb-master.start
	./ensure-started.sh $*-slave || \
          docker run --name $*-slave --link bb-master:master -d -v $(HOME)/hnet:/host-hnet:ro $*

# Netkit utilities

dsh: d-hnet-netkit.docker
	docker run --privileged -v $(HOME)/hnet/netkit/fs:/hnet/netkit/fs:ro -i -t d-hnet-netkit /bin/bash

ush: u-hnet-netkit.docker
	docker run --privileged -v $(HOME)/hnet/netkit/fs:/hnet/netkit/fs:ro -i -t u-hnet-netkit /bin/bash

.PHONY: clean
clean:    kill rm-exited $(DOCKERSUBDIRS:%=%.clean) uclean rmi-none

rm-exited:
	docker rm `docker ps -a | grep Exit | cut -d ' ' -f 1` 2>/dev/null || true

rmi-none:
	docker rmi `docker images | grep '<none>' | perl -pe 's/\s+/ /g' | cut -d ' ' -f 3` 2>/dev/null || true

# Testing target (derived from Debian, but not quite the same)

t-base.docker: t-base-rsync

t-base-rsync:
	rsync -a $(wildcard d-base/*.sh) t-base

t-hnet: d-hnet
	mkdir $@
	perl -pe 's/d-base/t-base/g' < d-hnet/Dockerfile | \
	perl -pe 's/d-hnet/t-hnet/g' > $@/Dockerfile

t-bb: d-bb
	mkdir $@
	perl -pe 's/d-hnet/t-hnet/g' < d-bb/Dockerfile | \
	perl -pe 's/debian/testing/g' | \
	perl -pe 's/d-bb/t-bb/g' \
		> $@/Dockerfile
	cp $(wildcard d-bb/*.sh) $@
	cp $(wildcard d-bb/*.py) $@

t-hnet-netkit: d-hnet-netkit
	mkdir $@
	perl -pe 's/d-hnet/t-hnet/g' < d-hnet-netkit/Dockerfile > $@/Dockerfile
	cp $(wildcard d-hnet-netkit/*.sh) $@


# Ubuntu target (derived from Debian, but not quite the same)

u-base.docker: u-base-rsync

u-base-rsync:
	rsync -a $(wildcard d-base/*.sh) u-base

u-hnet: d-hnet
	mkdir $@
	perl -pe 's/d-base/u-base/g' < d-hnet/Dockerfile | \
	perl -pe 's/d-hnet/u-hnet/g' > $@/Dockerfile

u-bb: d-bb
	mkdir $@
	perl -pe 's/d-hnet/u-hnet/g' < d-bb/Dockerfile | \
	perl -pe 's/debian/ubuntu/g' | \
	perl -pe 's/d-bb/u-bb/g' \
		> $@/Dockerfile
	cp $(wildcard d-bb/*.sh) $@
	cp $(wildcard d-bb/*.py) $@

u-hnet-netkit: d-hnet-netkit
	mkdir $@
	perl -pe 's/d-hnet/u-hnet/g' < d-hnet-netkit/Dockerfile > $@/Dockerfile
	cp $(wildcard d-hnet-netkit/*.sh) $@

# General pattern rules

%.docker:
	cd $* && docker build -t $* .

%.shell: %.docker
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
d-bb.docker: d-hnet.docker

t-hnet.docker: t-base.docker t-hnet
t-hnet-netkit.docker: t-hnet.docker t-hnet-netkit
t-bb.docker: t-hnet.docker t-bb

u-hnet.docker: u-base.docker u-hnet
u-hnet-netkit.docker: u-hnet.docker u-hnet-netkit
u-bb.docker: u-hnet.docker u-bb
