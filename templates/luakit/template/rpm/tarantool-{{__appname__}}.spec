Name: tarantool-{{__appname__}}
Version: 2.0.0
Release: 1%{?dist}
Summary: Lua module template for Tarantool
Group: Applications/Databases
License: BSD
URL: https://github.com/tarantool/modulekit
Source0: {{__appname__}}-%{version}.tar.gz
BuildArch: noarch
BuildRequires: tarantool-devel >= 1.6.8.0
Requires: tarantool >= 1.6.8.0

%description
This package provides a Lua module template for Tarantool.

%prep
%setup -q -n {{__appname__}}-%{version}

%check
./test/{{__appname__}}.test.lua

%install
# Create /usr/share/tarantool/{{__appname__}}
mkdir -p %{buildroot}%{_datadir}/tarantool/{{__appname__}}
# Copy init.lua to /usr/share/tarantool/{{__appname__}}/init.lua
cp -p {{__appname__}}/*.lua %{buildroot}%{_datadir}/tarantool/{{__appname__}}

%files
%dir %{_datadir}/tarantool/{{__appname__}}
%{_datadir}/tarantool/{{__appname__}}/
%doc README.md
%{!?_licensedir:%global license %doc}
%license LICENSE AUTHORS