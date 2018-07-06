Name: tarantool-{{__name__}}
Version: 2.0.0
Release: 1%{?dist}
Summary: Lua module template for Tarantool
Group: Applications/Databases
License: BSD
URL: https://github.com/tarantool/modulekit
Source0: {{__name__}}-%{version}.tar.gz
BuildArch: noarch
BuildRequires: tarantool-devel >= 1.6.8.0
Requires: tarantool >= 1.6.8.0

%description
This package provides a Lua module template for Tarantool.

%prep
%setup -q -n {{__name__}}-%{version}

%check
./test/{{__name__}}.test.lua

%install
# Create /usr/share/tarantool/{{__name__}}
mkdir -p %{buildroot}%{_datadir}/tarantool/{{__name__}}
# Copy init.lua to /usr/share/tarantool/{{__name__}}/init.lua
cp -p {{__name__}}/*.lua %{buildroot}%{_datadir}/tarantool/{{__name__}}

%files
%dir %{_datadir}/tarantool/{{__name__}}
%{_datadir}/tarantool/{{__name__}}/
%doc README.md
%{!?_licensedir:%global license %doc}
%license LICENSE AUTHORS