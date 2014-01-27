DESTDIR=
PKGDEST=
PKG=orm
VERSION=1.4.3

SUBDIRS := bin lib etc

all:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} all ) ; done

install:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} install ) ; done

uninstall:
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} uninstall ) ; done

clean:
	@rm -f build-stamp configure-stamp
	@rm -rf debian/$(PKG) debian/files
	@rm -f $(PKG).tar.gz
	for dir in ${SUBDIRS} ; do ( cd $$dir ; ${MAKE} clean ) ; done

dist: clean
	@rm -rf /tmp/$(PKG)-$(VERSION)
	@mkdir -p /tmp/$(PKG)-$(VERSION)
	@cp -rf * /tmp/$(PKG)-$(VERSION)
	@cd /tmp/$(PKG)-$(VERSION); rm -rf `find . -name ".svn"`
	@cd /tmp; tar czf $(PKG)-$(VERSION).tar.gz $(PKG)-$(VERSION)
	@cp -f /tmp/$(PKG)-$(VERSION).tar.gz .
	@rm -rf /tmp/$(PKG)-$(VERSION)/
	@rm -f /tmp/$(PKG)-$(VERSION).tar.gz

rpm: dist
	#cp $(PKG)-$(VERSION).tar.gz `rpm --eval '%_sourcedir'`
	#rpmbuild -bb ./$(PKG).spec
	rpmbuild -tb $(PKG)-$(VERSION).tar.gz
	@if [ -n "$(PKGDEST)" ]; then \
            mv `rpm --eval '%{_topdir}'`/RPMS/noarch/$(PKG)-*.noarch.rpm $(PKGDEST); \
        fi

deb:
	@if [ -n "$$UNSIGNED_OSCAR_PKG" ]; then \
        echo "dpkg-buildpackage -rfakeroot -us -uc"; \
        dpkg-buildpackage -rfakeroot -us -uc; \
    else \
        echo "dpkg-buildpackage -rfakeroot"; \
        dpkg-buildpackage -rfakeroot; \
    fi
	@if [ -n "$(PKGDEST)" ]; then \
        mv ../$(PKG)*.deb $(PKGDEST); \
    fi
