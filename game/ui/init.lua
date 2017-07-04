-- current directory where this file is located
local requiredir = ...
-- convenient function for requiring files from current directory
local function requireitem(item) return require(requiredir .. "." .. item) end 

-- get name of current file (should be init.lua)
local info = debug.getinfo(1,'S');
local thisfile = info.short_src:match("^.+/(.+)$")

-- iterate over all files in current directory (excluding current file) and require them into table
local components = {}
local files = love.filesystem.getDirectoryItems(requiredir)
for index, file in ipairs(files) do
	-- we dont want current file to be included
	if file ~= thisfile then
		-- get filename without extension
		local componentname = file:match("(.+)%..+")
		-- require file from current directory and add it to table
		components[componentname] = requireitem(componentname)
	end
end

-- return all available components that could be found in directory where this file is located
return components
