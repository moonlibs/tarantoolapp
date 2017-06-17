%define __distribution {{__appname__}}
%define __repo %{__distribution}

%if %{__autobuild__}
%define version PKG_VERSION
%else
%define version 0.01
%endif
%define release %(/bin/date +"%Y%m%d.%H%M")
%define pacakgename {{__appname__}}

%define app_dir /opt/%{__distribution}

Name:           %{__distribution}
Version:        %{version}
Release:        %{release}
Summary:        {{__appname__}}

Group:          tarantool/db
License:        proprietary
Source0:        %{__repo}.tar.gz

Requires: tarantool >= 1.6.8
BuildRequires: tarantool >= 1.6.8
BuildRequires: luarocks
BuildRequires: python-argparse
BuildRequires: python-yaml
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot

%description
{{__appname__}}

%prep
rm -rf %{__repo}
%setup -q -n %{__repo}

%build
make

mkdir -p ./%{name}-%{version}-%{release}-libs
python dep.py --meta-file=./meta.yaml --luarocks-tree=./%{name}-%{version}-%{release}-libs

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

install -d -m 0755 %{buildroot}/usr/share/%{pacakgename}  # for init.lua, app and extra libs
install -m 0644 ./init.lua %{buildroot}/usr/share/%{pacakgename}/
cp -aR ./app       %{buildroot}/usr/share/%{pacakgename}
cp -aR  ./%{name}-%{version}-%{release}-libs %{buildroot}/usr/share/%{pacakgename}/libs


install -d -m 0755 %{buildroot}/etc/%{pacakgename}  # for conf.lua
install -m 0644 ./conf.lua %{buildroot}/etc/%{pacakgename}/

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root)
%dir /usr/share/%{pacakgename}
%dir /etc/%{pacakgename}
/usr/share/%{pacakgename}/libs
/usr/share/%{pacakgename}/app

%config(noreplace) /usr/share/%{pacakgename}/init.lua
%config(noreplace) /etc/%{pacakgename}/conf.lua

%changelog
