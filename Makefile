PWD := $(shell pwd)
SCP := $(shell which scp)
SED := $(shell which sed)
ES  := $(shell which escript)
VER := $(shell cat ./Version)
FS  := username@file.server.address:~/path.in.home

.PHONY: proto codec compile shell test console-dev rel-dev rel-stage rel-prod

all: proto codec compile

proto:
	$(PWD)/script/gpb -pkgs -I $(PWD)/proto -o-erl $(PWD)/src -o-hrl $(PWD)/include $(PWD)/proto/*.proto

codec:
	$(ES) $(PWD)/script/codec.erl rover $(PWD)/proto/ $(PWD)/src

compile:
	$(PWD)/script/rebar3 compile

shell:
	$(PWD)/script/rebar3 shell

test:
	$(PWD)/script/rebar3 ct

console-dev:
	_build/dev/rel/rover/bin/rover console

rel-prod:
	$(SED) -i 's/{rover, "rover-version"}/{rover, "$(VER)"}/g' ./rebar.config
	$(PWD)/script/rebar3 as prod release
	$(PWD)/script/rebar3 as prod tar
	$(SED) -i 's/{rover, "$(VER)"}/{rover, "rover-version"}/g' ./rebar.config
    #$(SCP) -P 8522 $(PWD)/_build/prod/rel/rover/rover-$(VER).tar.gz $(FS)
	@printf "\nApplication: %s\n" $(PWD)/_build/prod/rel/rover/rover-$(VER).tar.gz

rel-stage:
	$(SED) -i 's/{rover, "rover-version"}/{rover, "$(VER)"}/g' ./rebar.config
	$(PWD)/script/rebar3 as stage release
	$(PWD)/script/rebar3 as stage tar
	$(SED) -i 's/{rover, "$(VER)"}/{rover, "rover-version"}/g' ./rebar.config
    #$(SCP) -P 8522 $(PWD)/_build/stage/rel/rover/rover-$(VER).tar.gz $(FS)
	@printf "\nApplication: %s\n" $(PWD)/_build/stage/rel/rover/rover-$(VER).tar.gz

rel-dev:
	$(PWD)/script/rebar3 as dev release

