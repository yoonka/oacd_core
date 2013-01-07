package = oacd_core
version = 2.0.0
tarname = $(package)
distdir = $(tarname)-$(version)

all: compile

compile:
	REBAR_SHARED_DEPS=1 rebar compile

clean:
	rebar clean
	-rm -rf $(distdir)
	-rm -rf $(distdir).tar.gz

check:
	REBAR_SHARED_DEPS=1 rebar eunit skip_deps=true

dist: $(distdir).tar.gz

$(distdir).tar.gz: $(distdir)
	tar chof - $(distdir) | gzip -9 -c > $@
	rm -rf $(distdir)

$(distdir): FORCE
	mkdir -p $(distdir)/src
	mkdir -p $(distdir)/include
	cp Makefile $(distdir)
	cp $(wildcard src/oacd_core.app.src) $(distdir)/src
	cp $(wildcard src/*.erl) $(distdir)/src
	cp $(wildcard include/*.hrl) $(distdir)/include

distcheck: $(distdir).tar.gz
	gzip -cd $(distdir).tar.gz | tar xvf -
	cd $(distdir) && $(MAKE) all
	cd $(distdir) && $(MAKE) check
	cd $(distdir) && $(MAKE) clean
	rm -rf $(distdir)
	@echo "*** Package $(distdir).tar.gz is ready for distribution."

FORCE:
	-rm $(distdir).tar.gz >/dev/null 2>&1
	-rm -rf $(distdir) >/dev/null 2>&1

# START Local dependency management
deps: getdeps updatedeps

getdeps:
	rebar get-deps

updatedeps:
	rebar update-deps
# END Local dependency management

.PHONY: FORCE compile dist distcheck getdeps