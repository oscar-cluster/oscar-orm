DESTDIR=

include ./Config.mk

SUBDIRS := bin lib

all:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} all ) ; done

install:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} install ) ; done

uninstall:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} uninstall ) ; done

clean:
	@rm -f build-stamp configure-stamp
	@rm -rf debian/orm debian/files
	@rm -f orm.tar.gz
	@rm -f orm.spec
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} clean ) ; done

dist: clean
	@rm -rf /tmp/orm
	@mkdir -p /tmp/orm
	@cp -rf * /tmp/orm
	@cd /tmp/orm; rm -rf `find . -name ".svn"`
	@cd /tmp; tar czf orm.tar.gz orm
	@cp -f /tmp/orm.tar.gz .
	@rm -rf /tmp/orm/
	@rm -f /tmp/orm.tar.gz

rpm: dist
	sed -e "s/PERLLIBPATH/$(SEDLIBDIR)/" < orm.spec.in \
        > orm.spec
	cp orm.tar.gz /usr/src/redhat/SOURCES
	rpmbuild -bb ./orm.spec

deb:
	dpkg-buildpackage -rfakeroot
