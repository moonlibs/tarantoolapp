package = "{{__name__}}"
version = "scm-1"
source = {
	-- url = "git+ssh://git@github.com:moonlibs/baselayout",
	url = "git+https://github.com/moonlibs/baselayout",
}
description = {
	homepage = "https://github.com/moonlibs/baselayout",
	license = "Artistic",
}
dependencies = {
	"kit scm-1",
	"config scm-2",
	"package-reload scm-1",

	"spacer scm-1",
	"moonwalker scm-1",
	"ffi-reloadable scm-1",
}
build = {
	type = "builtin",
	modules = {
	}
}
