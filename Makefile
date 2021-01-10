PROJECT := republicofdalmatia
SERVICE := dnsmasq
IMAGE   := $(PROJECT)/$(SERVICE)
CONTAINER	:= $(PROJECT)-$(SERVICE)
RUN_ARGS	:= -v $(CURDIR)/conf/dnsmasq.conf:/etc/dnsmasq.conf -v $(CURDIR)/conf/dnsmasq.leases:/var/lib/misc/dnsmasq.leases --privileged
CMD	:= --log-queries --log-dhcp
SHELL	:= /bin/bash
TAG	:= latest


kill:
	-docker kill $(CONTAINER)

stop:
	-docker stop $(CONTAINER)

clean: kill
	-docker rm $(CONTAINER) $(CONTAINER)_old
	-docker rmi $(IMAGE):$(TAG) $(IMAGE):obsolete

network:
	-docker network create --driver=bridge --attachable $(PROJECT)

archive:
	-docker tag $(IMAGE):$(TAG) $(IMAGE):obsolete

build: archive
	docker build -t $(IMAGE):$(TAG) .

run: backup build network
	docker run -d --restart=always --network=$(PROJECT) --name=$(CONTAINER) --hostname=$(CONTAINER) $(RUN_ARGS) $(IMAGE):$(TAG) $(CMD)
	docker ps | grep $(CONTAINER)

dry_run: backup build network
	docker run -it --rm --name=$(CONTAINER) --network=$(PROJECT) --hostname=$(CONTAINER) $(RUN_ARGS) --entrypoint=$(SHELL) $(IMAGE):$(TAG)

deploy: pull network
	docker run -d --restart=always --name=$(CONTAINER) --network=$(PROJECT) --hostname=$(CONTAINER) $(RUN_ARGS) $(IMAGE):$(TAG) $(CMD)

backup: stop
	-docker rm $(CONTAINER)_old
	-docker rename $(CONTAINER) $(CONTAINER)_old

pull:
	docker pull $(IMAGE):$(TAG)

upgrade: backup pull deploy logs

logs:
	docker logs -f $(CONTAINER)

exec:
	docker exec -it $(CONTAINER) $(SHELL)
