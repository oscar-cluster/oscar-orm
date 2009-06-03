DESTDIR=

TOPDIR=..
include $(TOPDIR)/Config.mk

SCRIPTS := repoCache.txt
SUBDIRS :=

all:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} all ) ; done

install: 
	install -d -m 0755 $(DESTDIR)/var/lib/oscar/cache
	install    -m 0755 ${SCRIPTS} $(DESTDIR)/var/lib/oscar/cache
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} install ) ; done

uninstall:
	cd $(DESTDIR)/var/lib/oscar/cache; rm -f ${SCRIPTS}
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} uninstall ) ; done

clean:
	@rm -f *~
