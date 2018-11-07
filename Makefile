# Makefile for creating container file
# Override these with environmental variables
VERSION?=1.11-r2

### Do not override below

user=legalio
app=nginx
version=$(VERSION)
#registry=docker.io
deps_dir=${PWD}/deps
go_static_builder=docker run --rm -v $(deps_dir):/go -e CGO_ENABLED=0 docker.io/hosh/golang-alpine:1.5.4
go_bin=$(go_static_builder) go

all: container

container: deps/bin/dinit deps/bin/go-dnsmasq
	docker build --tag=$(user)/$(app):$(version) .
	docker tag $(user)/$(app):$(version) $(user)/$(app):latest

push:
	docker push $(user)/$(app):$(version)

push-latest:
	docker push $(user)/$(app):latest

push-all: push push-latest

deps:
	mkdir -p deps

deps/bin/dinit: deps
	$(go_bin) get -v -a -tags netgo -installsuffix netgo github.com/miekg/dinit

deps/bin/go-dnsmasq: deps
	$(go_bin) get -v github.com/janeczku/go-dnsmasq


clean:
	rm -fr deps

.PHONY: all container push push-latest push-all clean
