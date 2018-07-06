local errno = require 'errno'
local fio = require 'fio'
local compat = require 'tarantoolapp.compat'
local util = require 'tarantoolapp.util'

local fileio = {}


local S_IFREG = tonumber('0100000', 8)  -- regular file
local S_IFDIR = tonumber('0040000', 8)  -- directory

local modes = fio.c.mode
local perms = bit.bor(modes.S_IRUSR, modes.S_IWUSR,
                      modes.S_IRGRP, modes.S_IWGRP,
                      modes.S_IROTH, modes.S_IWOTH)
local folder_perms = bit.bor(modes.S_IRUSR, modes.S_IWUSR, modes.S_IXUSR,
                             modes.S_IRGRP, modes.S_IWGRP, modes.S_IXGRP,
                             modes.S_IROTH,                modes.S_IXOTH)

 function fileio.get_mode(file_path)
	local f_mode = fio.stat(file_path).mode
	local is_directory = (bit.band(f_mode, S_IFDIR) > 0)
	local is_file = (bit.band(f_mode, S_IFREG) > 0)

	if is_directory then
		return 'directory'
	end
	return 'file'
end

function fileio.listdir(path, directory_first, recursive)
	if directory_first == nil then
		directory_first = true
	end

	if recursive == nil then
		recursive = true
	end

	local files = {}
	for _, postfix in ipairs({'/*', '/.*'}) do
		for _, file in ipairs(fio.glob(path .. postfix)) do
			local name = fio.basename(file)
			if name ~= "." and name ~= ".." then
				local mode = fileio.get_mode(file)

				if directory_first then
					table.insert(files, {
						mode = mode,
						path = file,
						name = name,
					})
				end
				if mode == "directory" and recursive then
					files = util.merge_tables(files, fileio.listdir(file))
				end

				if not directory_first then
					table.insert(files, {
						mode = mode,
						path = file,
						name = name,
					})
				end
			end
		end
	end
	return files
end

function fileio.read_file(filepath)
	local fh = fio.open(filepath, {'O_RDONLY'})
	if not fh then
		error(string.format("Failed to open file %s: %s", filepath, errno.strerror()))
	end

	local data = ''
	while true do
		local d = fh:read(4096)
		if d == '' or d == nil then
			break
		else
			data = data .. d
		end
	end
	fh:close()
	return data
end

function fileio.copyfile(src, dest)
	local src_fh = fio.open(src, {'O_RDONLY'})
	if not src_fh then
		error(string.format("Failed to open file %s: %s", src, errno.strerror()))
	end
	local src_mode = fio.stat(src).mode

	local local_perms = bit.bor(perms,
	                            bit.band(src_mode, fio.c.mode.S_IXUSR),
	                            bit.band(src_mode, fio.c.mode.S_IXGRP),
	                            bit.band(src_mode, fio.c.mode.S_IXOTH))

	local dest_fh = fio.open(dest, {'O_WRONLY', 'O_CREAT'}, local_perms)
	if not dest_fh then
		error(string.format("Failed to open file %s: %s", dest, errno.strerror()))
	end

	local data = nil
	while true do
		local d = src_fh:read(4096)
		if d == nil or d == '' then
			break
		else
			dest_fh:write(d)
		end
	end
	src_fh:close()
	dest_fh:close()
	return data
end

function fileio.copydir(src, dest)
	local files = fileio.listdir(src)

	local msrc, _ = src:gsub('([().%+-*?[^$])', '%%%1')

	assert(dest ~= nil)
	for _, f in ipairs(files) do
		local fmode, fpath = f.mode, f.path

		local filename = fio.basename(fpath)
		local filedir = fio.dirname(fpath)
		local relative_path = fpath:match(msrc .. '/(.*)')

		local p = fio.pathjoin(dest, relative_path)

		if fmode == 'directory' then
			fileio.mkdir(p, folder_perms)
		else
			if fio.lstat(fpath):is_link() then
				fio.symlink(fio.readlink(fpath), p)
			end
			fio.copyfile(fpath, p)
		end
	end
end


function fileio.mkdir(path)
	local ok = fio.mkdir(path, folder_perms)
	if not ok then
		error(string.format("Could not create folder %s: %s", path, errno.strerror()))
	end
end

fileio.path = {
	is_dir = function(path)
		if compat.check_version({1, 9}, _TARANTOOL) then
			return fio.path.is_dir(path)
		end

		local fs = fio.stat(path)
		return fs ~= nil and fs:is_dir() or false
	end,
	exists = function(path)
		if compat.check_version({1, 9}, _TARANTOOL) then
			return fio.path.exists(path)
		end
		return fio.stat(path) ~= nil
	end
}

return fileio
