Name: tarantool-{{__name__}}
Version: 2.0.0
Release: 1%{?dist}
Summary: C module template for Tarantool
Group: Applications/Databases
License: BSD
URL: https://github.com/tarantool/modulekit
Source0: {{__name__}}-%{version}.tar.gz
BuildRequires: cmake >= 2.8
BuildRequires: gcc >= 4.5
BuildRequires: tarantool-devel >= 1.6.8.0
BuildRequires: msgpuck-devel >= 1.0.0
BuildRequires: /usr/bin/prove
Requires: tarantool >= 1.6.8.0

%description
This package provides C module template for Tarantool.

%prep
%setup -q -n %{name}-%{version}

%build
%cmake . -DCMAKE_BUILD_TYPE=RelWithDebInfo
make %{?_smp_mflags}

%check
make %{?_smp_mflags} check

%install
%make_install

%files
%{_libdir}/tarantool/*/
%{_datarootdir}/tarantool/*/
%doc README.md
%{!?_licensedir:%global license %doc}
%license LICENSE AUTHORS
