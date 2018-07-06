%define __distribution {{__name__}}
%define __repo %{__distribution}

%if %{__autobuild__}
%define version PKG_VERSION
%else
%define version {{__version__}}
%endif
%define release %(/bin/date +"%Y%m%d.%H%M")
%define packagename {{__name__}}

%define app_dir /opt/%{__distribution}

Name:           %{__distribution}
Version:        %{version}
Release:        %{release}
Summary:        {{__name__}}

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
BuildRequires: lua-devel >= 5.1
BuildRequires: lua-devel < 5.2
BuildRequires: luarocks

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot

%description
{{__name__}}

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
# cd %{__dir}
make

mkdir -p ./%{name}-%{version}-%{release}-rocks
tarantool dep.lua --meta-file ./meta.yaml --tree ./%{name}-%{version}-%{release}-rocks

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}
%if %{?SRC_DIR:1}%{!?SRC_DIR:0}
    cd %{__repo}
%endif
#cd %{__dir}
install -d -m 0755 %{buildroot}/usr/share/%{packagename}  # for init.lua, app and extra rocks
install -m 0644 ./init.lua %{buildroot}/usr/share/%{packagename}/
cp -aR ./app       %{buildroot}/usr/share/%{packagename}
cp -aR ./%{name}-%{version}-%{release}-rocks %{buildroot}/usr/share/%{packagename}/.rocks

install -d -m 0755 %{buildroot}/etc/%{packagename}  # for conf.lua
install -m 0644 ./conf.lua %{buildroot}/etc/%{packagename}/conf.lua

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
%dir /usr/share/%{packagename}
%dir /etc/%{packagename}
/usr/share/%{packagename}/.rocks
/usr/share/%{packagename}/app

%config(noreplace) /usr/share/%{packagename}/init.lua
%config(noreplace) /etc/%{packagename}/conf.lua

%changelog
