Summary:        OSCAR Repository Manager - ORM.
Name:           orm
Version:        1.4.3
Release:        2
Vendor:         Open Cluster Group <http://OSCAR.OpenClusterGroup.org/>
Distribution:   OSCAR
Packager:       Geoffroy Vallee <valleegr@ornl.gov>
License:        GPL
Group:          Development/Libraries
Source:         %{name}.tar.gz
BuildRoot:      %{_localstatedir}/tmp/%{name}-root
BuildArch:      noarch
AutoReqProv: 	no
Requires:       oscar-base-lib > 6.0.2
Requires:       packman

%description
Set of scripts and Perl modules for the management of the OSCAR repositories.

%prep
%setup -n %{name}

%install
%__make install DESTDIR=$RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{_bindir}/*
%{perl_vendorlib}/*
%{_mandir}/man1/*
/var/lib/oscar/*

%changelog
* Thu Nov 28 2013 DongInn Kim <dikim@cs.indiana.edu> 1.4.3-2
- New upstream version (see ChangeLog for more details).
- Update the release number of a spec file to get the updated RepositoryManager.pm
* Wed Nov 14 2012 Olivier Lahaye <olivier.lahaye@cea.fr> 1.4.3-1
- New upstream version (see ChangeLog for more details).
- Updated spec file with rpm macros for paths.
* Fri Oct 30 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.4.2-1
- New upstream version (see ChangeLog for more details).
* Fri Sep 25 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.4.1-1
- New upstream version (see ChangeLog for more details).
* Thu Jul 16 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.4.0-1
- New upstream version (see ChangeLog for more details).
* Thu Apr 30 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.3-2
- Add a dependencies to packman.
* Thu Apr 23 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.3-1
- New upstream version (see ChangeLog for more details).
* Fri Mar 20 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.2.2-1
- New upstream version (see ChangeLog for more details).
* Mon Feb 09 2009 Geoffroy Vallee <valleegr@ornl.gov> 1.2.1-1
- New upstream version (see ChangeLog for more details).
* Thu Dec 04 2008 Geoffroy Vallee <valleegr@ornl.gov> 1.2-3
- Move the libraries into a noarch directory.
* Fri Nov 28 2008 Geoffroy Vallee <valleegr@ornl.gov> 1.2-2
- Disable automatic dependencies.
* Wed Nov 26 2008 Geoffroy Vallee <valleegr@ornl.gov> 1.2-1
- new upstream version (see ChangeLog for more details).
* Mon Sep 22 2008 Geoffroy Vallee <valleegr@ornl.gov> 1.1-1
- new upstream version (see ChangeLog for more details).
* Thu Sep 04 2008 Geoffroy Vallee <valleegr@ornl.gov> 1.0-1
- new upstream version (see ChangeLog for more details).
