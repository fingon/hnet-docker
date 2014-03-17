DOCKERSUBDIRS=\
  d-base d-hnet d-hnet-netkit \
  u-base u-hnet u-hnet-netkit

# u-base is as-is (too much diff to d-base).
# u-hnet and u-hnet-netkit are created as copies of d-hnet*, and then modified
MADESUBDIRS=u-hnet u-hnet-netkit

DOCKERBUILDS?=$(DOCKERSUBDIRS:%=%.docker)
DOCKERCLEANS?=$(DOCKERSUBDIRS:%=%.clean)

all: $(DOCKERBUILDS)

dsh: all
	docker run --privileged -v $(HOME)/hnet/netkit/fs:/hnet/netkit/fs:ro -i -t d-hnet-netkit /bin/bash

ush: all
	docker run --privileged -v $(HOME)/hnet/netkit/fs:/hnet/netkit/fs:ro -i -t u-hnet-netkit /bin/bash

clean: $(DOCKERCLEANS) uclean rmi-none

rm-exited:
	docker rm `docker ps -a | grep Exit | cut -d ' ' -f 1` 2>/dev/null || true

rmi-none:
	docker rmi `docker images | grep '<none>' | perl -pe 's/\s+/ /g' | cut -d ' ' -f 3` 2>/dev/null || true

u-base.docker: u-base-rsync

u-base-rsync:
	rsync -a $(wildcard d-base/*.sh) u-base

u-hnet: d-hnet
	mkdir $@
	perl -pe 's/d-base/u-base/g' < d-hnet/Dockerfile | \
	perl -pe 's/d-hnet/u-hnet/g' > $@/Dockerfile

u-hnet-netkit: d-hnet-netkit
	mkdir $@
	perl -pe 's/d-hnet/u-hnet/g' < d-hnet-netkit/Dockerfile > $@/Dockerfile
	cp $(wildcard d-hnet-netkit/*.sh) $@

%.docker: %
	(cd $* && docker build -t $* .)

uclean:
	rm -rf $(MADESUBDIRS)

%.clean: rm-exited
	-docker rmi $*

# Manual dependencies (so we can use make -j N)
d-hnet.docker: d-base.docker
d-hnet-netkit.docker: d-hnet.docker
u-hnet.docker: u-base.docker
u-hnet-netkit.docker: u-hnet.docker
