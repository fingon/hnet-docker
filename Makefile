DOCKERSUBDIRS=\
  d-base d-hnet d-hnet-netkit \
  u-base u-hnet u-hnet-netkit \
  buildbot-master

# u-base is as-is (too much diff to d-base).
# u-hnet and u-hnet-netkit are created as copies of d-hnet*, and then modified
MADESUBDIRS=u-hnet u-hnet-netkit u-bb

DOCKERBUILDS?=$(DOCKERSUBDIRS:%=%.docker)
DOCKERCLEANS?=$(DOCKERSUBDIRS:%=%.clean)

all: $(DOCKERBUILDS)

start: bb-start dbb-start ubb-start

stop: bb-stop dbb-stop ubb-stop

dbb-start: d-bb.docker bb-start
	./ensure-started.sh d-bb-slave || \
          docker run --name d-bb-slave -link bb-master:master -d -v $(HOME)/hnet:/host-hnet d-bb

ubb-start: u-bb.docker bb-start
	./ensure-started.sh u-bb-slave || \
          docker run --name u-bb-slave -link bb-master:master -d -v $(HOME)/hnet:/host-hnet u-bb

bb-start: buildbot-master.docker
	./ensure-started.sh bb-master || \
          docker run --name bb-master -d -p 8010:8010 -v $(HOME)/hnet:/host-hnet buildbot-master

bb-stop:
	-docker stop bb-master

dbb-stop:
	-docker stop d-bb-slave

ubb-stop:
	-docker stop u-bb-slave

dsh: d-hnet-netkit.docker
	docker run --privileged -v $(HOME)/hnet/netkit/fs:/hnet/netkit/fs:ro -i -t d-hnet-netkit /bin/bash

ush: u-hnet-netkit.docker
	docker run --privileged -v $(HOME)/hnet/netkit/fs:/hnet/netkit/fs:ro -i -t u-hnet-netkit /bin/bash

clean:    stop $(DOCKERCLEANS) uclean rmi-none

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

u-bb: d-bb
	mkdir $@
	perl -pe 's/d-hnet/u-hnet/g' < d-bb/Dockerfile | \
	perl -pe 's/debian/ubuntu/g' | \
	perl -pe 's/d-bb/u-bb/g' \
		> $@/Dockerfile
	cp $(wildcard d-bb/*.sh) $@

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
buildbot-master.docker: d-base.docker
d-hnet.docker: d-base.docker
d-hnet-netkit.docker: d-hnet.docker
u-hnet.docker: u-base.docker
u-hnet-netkit.docker: u-hnet.docker
d-bb.docker: d-hnet.docker
u-bb.docker: u-hnet.docker
