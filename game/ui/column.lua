local requiredir = (...):match("(.-)[^%.]+$")
local function requireitem(item) return require(requiredir .. item) end

local Item = requireitem("item")
local util = requireitem("util")

local Column = Item:extend("column")
function Column:new()
	self.super.new(self)
	self.width = self.width or 0
	self.height = self.height or 0
	self.spacing = self.spacing or 10
	self.bindings = self:createBindings()
end

function Column:update()
	self:evaluateBindings(self.bindings)
	self.width, self.height = self:layout()
	self.super.update(self)
end

function Column:layout()
	local lwidth, lheight = 0, 0

	for index, child in ipairs(self) do
		child.x = self.x
		child.y = self.y + lheight
		
		if not child.name then
			child.spacing = self.spacing
			child.width, child.height = self.layout(child)
		end

		lheight = lheight + child.height + util.calculateSpacing(self.spacing, child.height, index, #self)
		if child.width > lwidth then
			lwidth = child.width
		end
	end

	return lwidth, lheight
end

return Column