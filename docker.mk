

#  $(1) - dockerfile (optional)
#  $(2) - docker registry (optional)
#  $(3) - docker organisation (optional)
#  $(4) - image name
#  $(5) - image version (optional)
#  $(6) - docker build context (optional)

define DOCKER_BUILD
docker-build-$(4) \
docker-push-$(4)  \
docker-rm-$(4)    : _dockerfile:=$(if $(1),$(1),Dockerfile)

docker-build-$(4) \
docker-push-$(4)  \
docker-rm-$(4)    : _registry:=$(if $(2),$(2)/,)

docker-build-$(4) \
docker-push-$(4)  \
docker-rm-$(4)    : _org:=$(if $(3),$(3)/,)

docker-build-$(4) \
docker-push-$(4)  \
docker-rm-$(4)    : _image_version:=$$(_registry)$$(_org)$(4):$(if $(5),$(5),$$(call GET_IMAGE_VERSION))

docker-build-$(4) \
docker-push-$(4)  \
docker-rm-$(4)    : _image_latest:=$$(_registry)$$(_org)$(4):latest

docker-build-$(4) \
docker-push-$(4)  \
docker-rm-$(4)    : _context:=$(if $(6),$(6),.)

.PHONY: docker-build-$(4)
docker-build: docker-build-$(4)
docker-build-$(4): $$(_dockerfile)
	$(call PROMPT,Build $$(_image_version))
	docker build --rm --force-rm -t $$(_image_version) -f $$(_dockerfile) $$(_context)
	[ "$$(_image_version)" == "$$(_image_latest)" ] || docker tag $$(_image_version) $$(_image_latest)

.PHONY: docker-push-$(4)
docker-push: docker-push-$(4)
docker-push-$(4):
	$(call PROMPT,Push $$(_image_version))
	docker push $$(_image_version)
	docker push $$(_image_latest)

.PHONY: docker-rm-$(4)
docker-rm-$(4):
	-docker image rm -f $$(_image_version)
	-docker image rm -f $$(_image_latest)

clean:: docker-rm-$(4)
endef

.PHONY: clean
clean::

GIT_TAG:=$(patsubst v%,%,$(shell git describe --tags 2> /dev/null))
define GET_IMAGE_VERSION
$(if $(GIT_TAG),$(GIT_TAG),latest)
endef

ifndef PROMPT
define PROMPT
	@echo
	@echo "***************************************************************************"
	@echo "*"
	@echo "*     $(1)"
	@echo "*"
	@echo "***************************************************************************"
	@echo
endef
endif

.PHONY: docker-login
docker-login:
	echo "$$DOCKER_PASSWORD" | docker login -u "$$DOCKER_USERNAME" --password-stdin $(DOCKER_REGISTRY)

#----------------------------------------------------------
#  define a few helper rules for installing common apps

CA_BUNDLE:=.cache/ca-bundle.crt
DUMB_INIT:=.cache/bin/dumb-init
CONSUL_TEMPLATE:=.cache/bin/consul-template

CONSUL_TEMPLATE_VERSION?=0.19.4

# Useful with a scratch container. Use in Dockerfile as:
#
#   ADD .cache/ca-bundle.crt /etc/pki/tls/certs/ca-bundle.crt
$(CA_BUNDLE): .cache
	curl -sL https://mkcert.org/generate/ > $@

$(DUMB_INIT): .cache/bin
	$(call PROMPT,Downloading dumb-init)
	curl -sL https://github.com/boyvinall/dumb-init/releases/download/latest/dumb-init > $@
	chmod +x $@
	touch $@

$(CONSUL_TEMPLATE): .cache/bin
	$(call PROMPT,Downloading consul-template)
	curl -sL https://releases.hashicorp.com/consul-template/$(CONSUL_TEMPLATE_VERSION)/consul-template_$(CONSUL_TEMPLATE_VERSION)_linux_amd64.tgz | tar -xz -f- -C$(dir $@)
	chmod +x $@
	touch $@

.cache .cache/bin:
	mkdir -p $@

.PHONY: clobber
clobber:: clean
	rm -rf .cache
