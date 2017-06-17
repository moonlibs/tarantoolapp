%define __distribution {{__appname__}}
%define __repo %{__distribution}

%if %{__autobuild__}
%define version PKG_VERSION
%else
%define version 0.01
%endif
%define release %(/bin/date +"%Y%m%d.%H%M")
%define packagename {{__appname__}}

%define app_dir /opt/%{__distribution}

Name:           %{__distribution}
Version:        %{version}
Release:        %{release}
Summary:        {{__appname__}}

Group:          tarantool/db
License:        proprietary

%if %{__autobuild__}
Packager: BUILD_USER
Source0: %{__repo}-GIT_TAG.tar.bz2
%else
%if %{?SRC_DIR:0}%{!?SRC_DIR:1}
Source0: %{__repo}.tar.bz2
%endif
%endif

Requires: tarantool >= 1.6.8
BuildRequires: git
BuildRequires: tarantool >= 1.6.8
BuildRequires: tarantool-devel >= 1.6.8
BuildRequires: lua-devel > 5.1
BuildRequires: lua-devel < 5.2
BuildRequires: luarocks
BuildRequires: python-argparse
BuildRequires: python-yaml

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot

%description
{{__appname__}}

%prep
%if %{?SRC_DIR:1}%{!?SRC_DIR:0}
    rm -rf %{__repo}
    cp -ravi %{SRC_DIR} %{__repo}
    cd %{__repo}
%else
%setup -q -n %{__repo}
%endif

%build
%if %{?SRC_DIR:1}%{!?SRC_DIR:0}
    cd %{__repo}
%endif
cd %{__dir}
make

mkdir -p ./%{name}-%{version}-%{release}-libs
python dep.py --meta-file=./meta.yaml --luarocks-tree=./%{name}-%{version}-%{release}-libs

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}
%if %{?SRC_DIR:1}%{!?SRC_DIR:0}
    cd %{__repo}
%endif
cd %{__dir}
install -d -m 0755 %{buildroot}/usr/share/%{packagename}  # for init.lua, app and extra libs
install -m 0644 ./init.lua %{buildroot}/usr/share/%{packagename}/
cp -aR ./app       %{buildroot}/usr/share/%{packagename}
cp -aR  ./%{name}-%{version}-%{release}-libs %{buildroot}/usr/share/%{packagename}/libs

install -d -m 0755 %{buildroot}/etc/%{packagename}  # for conf.lua
install -m 0644 ./conf.inst.lua %{buildroot}/etc/%{packagename}/conf.lua

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
%dir /usr/share/%{packagename}
%dir /etc/%{packagename}
/usr/share/%{packagename}/libs
/usr/share/%{packagename}/app

%config(noreplace) /usr/share/%{packagename}/init.lua
%config(noreplace) /etc/%{packagename}/conf.lua

%changelog
