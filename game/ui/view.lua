local requiredir = (...):match("(.-)[^%.]+$")
local function requireitem(item) return require(requiredir .. item) end

local Item = requireitem("item")

local View = Item:extend("view")
function View:new()
	self.super.new(self)
	self.width = self.width or love.graphics.getWidth()
	self.height = self.height or love.graphics.getHeight()
end

return View
