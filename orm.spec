#define is_suse %(test -f /etc/SuSE-release && echo 1 || echo 0)
%define is_suse %(grep -E "(suse)" /etc/os-release > /dev/null 2>&1 && echo 1 || echo 0)

Summary:        OSCAR Repository Manager - ORM.
Name:           orm
Version:        1.4.3
Release:        5%{?dist}
Vendor:         Open Cluster Group <http://OSCAR.OpenClusterGroup.org/>
Distribution:   OSCAR
Packager:       Geoffroy Vallee <valleegr@ornl.gov>
License:        GPL
Group:          Development/Libraries
Source:         %{name}-%{version}.tar.gz
BuildRoot:      %{_localstatedir}/tmp/%{name}-root
BuildArch:      noarch
Requires:       liboscar-server >= 6.3
Requires:       packman
%if 0%{?fedora} >= 16 || 0%{?rhel} >= 6
BuildRequires:  perl-generators, perl-interpreter
%endif
%if 0%{?is_suse}%{?is_opensuse}
BuildRequires:  rpm, perl
%endif
BuildRequires:	make
BuildRequires:	perl(Pod::Man)

%description
Set of scripts and Perl modules for the management of the OSCAR repositories.

%prep
%setup -n %{name}-%{version}

%install
%__make install DESTDIR=$RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{_bindir}/*
%{perl_vendorlib}/OSCAR/*
%{_mandir}/man1/*
%{_sharedstatedir}/oscar

%changelog
* Mon Jan 27 2014 Olivier Lahaye <olivier.lahaye@cea.fr> 1.4.3-5
- Added version to sourcename (new oscar-packager).
* Sat Dec 14 2013 Olivier Lahaye <olivier.lahaye@cea.fr> 1.4.3-4
- Fix bad migration: /var/lib/oscar/cache is not in usr.
- Removed AutoReqProv: no so we have correct requires and provides.
- removed %dir %{perl_vendorlib}/OSCAR as we do now own it (conflict on fc-18+)
* Mon Dec 02 2013 Olivier Lahaye <olivier.lahaye@cea.fr> 1.4.3-3
- Migration from /var/lib/oscar/{package,testing} to /usr/lib/oscar (FHS)
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
