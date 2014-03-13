DOCKERSUBDIRS=d-dev d-hnet-dev d-hnet-netkit-env

DOCKERBUILDS?=$(DOCKERSUBDIRS:%=%.docker)
DOCKERCLEANS?=$(DOCKERSUBDIRS:%=%.clean)

all: $(DOCKERBUILDS)

dsh: all
	docker run --privileged -v $(HOME)/hnet/netkit/fs:/hnet/netkit/fs:ro -i -t d-hnet-netkit-env /bin/bash

clean: $(DOCKERCLEANS)

rmexited:
	docker rm `docker ps -a | grep Exit | cut -d ' ' -f 1` 2>/dev/null || true

%.docker:
	(cd $* && docker build -t $* .)

%.clean: rmexited
	-docker rmi $*
