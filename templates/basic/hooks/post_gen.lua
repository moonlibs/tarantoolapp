local project_opts = project_opts

local fio = require 'fio'

if not project_opts.use_spacer then
    fio.unlink(fio.pathjoin('app', 'schema.lua'))
end