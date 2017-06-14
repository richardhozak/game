local util = require("util")

local Item = require("ui.item")
local Button = Item:extend()

function Button:new(ui, world, x, y, width, height, options)
    Button.super.new(self, ui, world, x, y, width, height)
    self.color = options.color
    self.text = options.text
    self.pressedEmitted = false
    self.onPressed = options.onPressed
    self.font = love.graphics.getFont()
end

function Button:update(dt)
	Button.super.update(self, dt)
	if self.isPressed then
		if not self.pressedEmitted then
			self.pressedEmitted = true
			self.onPressed()
		end
	else
		self.pressedEmitted = false
	end
end

function Button:draw()
	util.drawFilledRectangle(self.x, self.y, self.width, self.height, unpack(self.color))
	if self.isPressed then
		love.graphics.setColor(255,255,255)
	end
	local centerX, centerY = self:getCenter()
	local text = type(self.text) == "function" and self.text() or self.text
	local textX = centerX - self.font:getWidth(text) / 2
	local textY = centerY - self.font:getHeight() / 2
	textX = math.floor(textX)
	textY = math.floor(textY)
	love.graphics.print(text, textX, textY)
end

--[[
function Button:pressed()
	if self.gotPressed then
		return false
	else
		return self.isPressed
	end
end
--]]

return Button