local lume = require("lib.lume")

local Entity = require("entities.entity")
local Item = Entity:extend()

function Item:new(ui, world, x, y, width, height)
	Item.super.new(self, world, x, y, width, height)
	self.ui = ui
	self.mouseOver = false
	self.isPressed = false
end

function Item:update(dt)
	local mouseX, mouseY = self.ui:getMousePosition()
	local isMouseDown = self.ui:isMouseDown()
	local items, len = self.world:queryPoint(mouseX, mouseY)
	self.mouseOver = lume.any(items, function(item) return item == self end)
	self.isPressed = self.mouseOver and isMouseDown
end

function Item:draw()
end

return Item