local requiredir = (...):match("(.-)[^%.]+$")
local function requireitem(item) return require(requiredir .. item) end

local Item = requireitem("item")
local util = requireitem("util")

local Row = Item:extend("row")
function Row:new()
	self.super.new(self)
	self.width = self.width or 0
	self.height = self.height or 0
	self.spacing = self.spacing or 10
	self.bindings = self:createBindings()
end

function Row:update()
	self:evaluateBindings(self.bindings)
	self.width, self.height = self:layout()
	self.super.update(self)
end

function Row:layout()
	local lwidth, lheight = 0, 0

	for index, child in ipairs(self) do
		child.x = self.x + lwidth
		child.y = self.y
		
		if not child.name then
			child.width, child.height  = self.layout(child)
		end

		lwidth = lwidth + child.width + util.calculateSpacing(self.spacing, child.width, index, #self)
		if child.height > lheight then
			lheight = child.height
		end
	end

	return lwidth, lheight
end

return Row