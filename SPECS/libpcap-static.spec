# $Id$
# Authority: dag

# Tag: rft
# ExclusiveDist: el6

Summary: System-independent interface for user-level packet capture
Name: libpcap
Epoch: 14
Version: 1.4.0
Release: 1%{?dist}
Group: Development/Libraries
License: BSD with advertising
URL: http://www.tcpdump.org

Packager: Dag Wieers <dag@wieers.com>
Vendor: Dag Apt Repository, http://dag.wieers.com/apt/

Source: http://www.tcpdump.org/release/%{name}-%{version}.tar.gz
Patch1: libpcap-man.patch
Patch2: libpcap-multilib.patch
Patch3: libpcap-s390.patch

BuildRequires: bison
BuildRequires: bluez-libs-devel
BuildRequires: flex
BuildRequires: glibc-kernheaders >= 2.2.0
BuildRoot: %{_tmpdir}/%{name}-%{version}-%{release}

%description
Libpcap provides a portable framework for low-level network
monitoring.  Libpcap can provide network statistics collection,
security monitoring and network debugging.  Since almost every system
vendor provides a different interface for packet capture, the libpcap
authors created this system-independent API to ease in porting and to
alleviate the need for several system-dependent packet capture modules
in each application.

Install libpcap if you need to do low-level network traffic monitoring
on your network.

%package devel
Summary: Libraries and header files for the libpcap library
Group: Development/Libraries
Requires: %{name} = %{epoch}:%{version}-%{release}

%description devel
Libpcap provides a portable framework for low-level network
monitoring.  Libpcap can provide network statistics collection,
security monitoring and network debugging.  Since almost every system
vendor provides a different interface for packet capture, the libpcap
authors created this system-independent API to ease in porting and to
alleviate the need for several system-dependent packet capture modules
in each application.

This package provides the libraries, include files, and other
resources needed for developing libpcap applications.

%prep
%setup

%patch1 -p1 -b .man
%patch2 -p1 -b .multilib
%patch3 -p1 -b .s390

#sparc needs -fPIC
%ifarch %{sparc}
sed -i -e 's|-fpic|-fPIC|g' configure
%endif

%build
export CFLAGS="%{optflags} -fno-strict-aliasing"
%configure
# --disable-static
%{__make} %{?_smp_mflags}

%install
%{__rm} -rf %{buildroot}
%{__make} install DESTDIR="%{buildroot}"

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(-, root, root, 0755)
%doc CHANGES CREDITS LICENSE README
%doc %{_mandir}/man7/pcap*.7*
%{_libdir}/libpcap.so.*
#%exclude %{_libdir}/libpcap.a
%{_libdir}/libpcap.a


%files devel
%defattr(-, root, root, 0755)
%doc %{_mandir}/man1/pcap-config.1*
%doc %{_mandir}/man3/pcap*.3*
%doc %{_mandir}/man5/pcap*.5*
%{_bindir}/pcap-config
%{_includedir}/pcap*.h
%{_includedir}/pcap/
%{_libdir}/libpcap.so

%changelog
* Wed May 22 2013 Dag Wieers <dag@wieers.com> - 14:1.4.0-1
- Updated to release 1.4.0

* Tue Mar 26 2013 Michal Sekletar <msekleta@redhat.com> - 14:1.3.0-4
- remove unused variable from pcap-config to prevent multilib conflicts
- specfile cleanup

* Thu Feb 14 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 14:1.3.0-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Thu Jul 19 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 14:1.3.0-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Wed Jun 13 2012 Michal Sekletar <msekleta@redhat.com> 14:1.3.0-1
- Update to 1.3.0

* Thu Jan 05 2012 Jan Synáček <jsynacek@redhat.com> 14:1.2.1-2
- Rebuilt for GCC 4.7

* Tue Jan 03 2012 Jan Synáček <jsynacek@redhat.com> 14:1.2.1-1
- Update to 1.2.1
- Drop unnecessary -fragment patch

* Fri Dec 02 2011 Michal Sekletar <msekleta@redhat.com> 14:1.2.0-1
- update to 1.2.0

* Tue Sep 06 2011 Michal Sekletar <msekleta@redhat.com> 14:1.1.1-4
- fix capture of fragmented ipv6 packets

* Fri Apr 22 2011 Miroslav Lichvar <mlichvar@redhat.com> 14:1.1.1-3
- ignore /sys/net/dev files on ENODEV (#693943)
- drop ppp patch
- compile with -fno-strict-aliasing

* Tue Feb 08 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 14:1.1.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Tue Apr 06 2010 Miroslav Lichvar <mlichvar@redhat.com> 14:1.1.1-1
- update to 1.1.1

* Wed Dec 16 2009 Miroslav Lichvar <mlichvar@redhat.com> 14:1.0.0-5.20091201git117cb5
- update to snapshot 20091201git117cb5

* Sat Oct 17 2009 Dennis Gilmore <dennis@ausil.us> 14:1.0.0-4.20090922gite154e2
- use -fPIC on sparc arches

* Wed Sep 23 2009 Miroslav Lichvar <mlichvar@redhat.com> 14:1.0.0-3.20090922gite154e2
- update to snapshot 20090922gite154e2
- drop old soname

* Fri Jul 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 14:1.0.0-2.20090716git6de2de
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Wed Jul 22 2009 Miroslav Lichvar <mlichvar@redhat.com> 14:1.0.0-1.20090716git6de2de
- update to 1.0.0, git snapshot 20090716git6de2de

* Wed Feb 25 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 14:0.9.8-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Fri Jun 27 2008 Miroslav Lichvar <mlichvar@redhat.com> 14:0.9.8-3
- use CFLAGS when linking (#445682)

* Tue Feb 19 2008 Fedora Release Engineering <rel-eng@fedoraproject.org> - 14:0.9.8-2
- Autorebuild for GCC 4.3

* Wed Oct 24 2007 Miroslav Lichvar <mlichvar@redhat.com> 14:0.9.8-1
- update to 0.9.8

* Wed Aug 22 2007 Miroslav Lichvar <mlichvar@redhat.com> 14:0.9.7-3
- update license tag

* Wed Jul 25 2007 Jesse Keating <jkeating@redhat.com> - 14:0.9.7-2
- Rebuild for RH #249435

* Tue Jul 24 2007 Miroslav Lichvar <mlichvar@redhat.com> 14:0.9.7-1
- update to 0.9.7

* Tue Jun 19 2007 Miroslav Lichvar <mlichvar@redhat.com> 14:0.9.6-1
- update to 0.9.6

* Tue Nov 28 2006 Miroslav Lichvar <mlichvar@redhat.com> 14:0.9.5-1
- split from tcpdump package (#193657)
- update to 0.9.5
- don't package static library
- maintain soname
