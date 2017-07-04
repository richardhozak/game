local requiredir = (...):match("(.-)[^%.]+$")
local function requireitem(item) return require(requiredir .. item) end

local Item = requireitem("item")

local View = Item:extend("view")
function View:new()
	self.x = self.x or 0
	self.y = self.y or 0
	self.width = self.width or love.graphics.getWidth()
	self.height = self.height or love.graphics.getHeight()
end

return View
