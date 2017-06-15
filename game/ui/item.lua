local lume = require("lib.lume")

local Object = require("lib.classic")
local Item = Object:extend()

function Item:new(ui, x, y, width, height)
	self.x, self.y = x, y
	self.width, self.height = width, height
	self.ui = ui
	self.mouseOver = false
	self.isPressed = false
end

function Item:update(dt)
	local mouseX, mouseY = self.ui:getMousePosition()
	local isMouseDown = self.ui:isMouseDown()
	self.mouseOver = self:containsMouse(mouseX, mouseY)
	self.isPressed = self.mouseOver and isMouseDown
end

function Item:containsMouse(x, y)
	return (x >= self.x and x <= self.x + self.width) and (y >= self.y and y <= self.y + self.height)
end

function Item:draw()
end

function Item:getCenter()
    return self.x + self.width / 2, 
           self.y + self.height / 2
end

return Item