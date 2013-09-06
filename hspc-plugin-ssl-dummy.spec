Name: hspc-plugin-ssl-dummy
Summary: Parallels Business Automation - Standard SSL Certificate: Dummy Plug-in
Source: %{name}.tar.bz2
Version:	%{version}
Release:	%{release}
Group:	Plug-Ins/SSL Certificate
License: Commercial
Vendor: Parallels
BuildRoot: %{_tmppath}/%{name}-%{version}-root
Obsoletes: hspc-ssl-plugin-dummy
Requires: hspc-release
AutoReqProv: no

%description
Parallels Business Automation - Standard SSL Certificate: Dummy Plug-in

%prep
rm -rf $RPM_BUILD_ROOT

%setup -n %{name} -q

%build
make PREFIX=$RPM_BUILD_ROOT

%install
rm -rf $RPM_BUILD_ROOT
make PREFIX=$RPM_BUILD_ROOT install
/usr/lib/rpm/brp-compress
find $RPM_BUILD_ROOT -type f -print | sed "s@^$RPM_BUILD_ROOT@@g" | grep -v perllocal.pod | grep -v "/CVS" | grep -v ".packlist" > %{name}-%{version}-filelist

%post
/usr/sbin/hspc-upgrade-manager --verbose --register ssl/plugin-ssl-dummy

%preun
if [ $1 = 0 ]; then
	/usr/sbin/hspc-upgrade-manager --clean plugin-ssl-dummy
fi

%clean
rm -rf $RPM_BUILD_ROOT

%files -f %{name}-%{version}-filelist
%defattr(-, root, root)
%attr(-, root, root)   %{_datadir}/hspc-upgrade/upgrade/plugin-ssl-dummy

%changelog

