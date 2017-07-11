local requiredir = (...):match("(.-)[^%.]+$")
local function requireitem(item) return require(requiredir .. item) end

local util = requireitem("util")
local Item = requireitem("item")
local Slider = Item:extend("slider")

function Slider:new()
	self.super.new(self)
	self.width = self.width or 100
	self.height = self.height or 25
	self.min = self.min or 0
	self.max = self.max or 100
	self.position = 0.5
end

function Slider:update()
	self.super.update(self)
end

function Slider:mousePressed(x, y, button, istouch)
	if self.super.mousePressed(self, x, y, button, istouch) then
		return true
	end

	local localX = x - self.x
	self.position = localX / self.width

	self.down = true
end

function Slider:mouseReleased(x, y, button, istouch)
	if self.down then
		self.down = false
		return true
	end

	return self.super.mousePressed(self, x, y, button, istouch)
end

function Slider:mouseMoved(x, y, dx, dy, istouch)
	if self.super.mouseMoved(self, x, y, dx, dy, istouch) then
		return true
	end

	if self.down then
		local localX = x - self.x
		self.position = util.clamp(localX / self.width, 0, 1)
		util.emit(self.onValue, self.max * self.position)
		return true
	else
		return false
	end
end

function Slider:drawHandle()
	local xOffset = (self.width - self.height) * self.position + self.height / 2
	local yOffset = self.height / 2
	love.graphics.setColor(255,255,255)
	love.graphics.circle("fill", self.x + xOffset, self.y + yOffset, self.height / 2)
	love.graphics.circle("line", self.x + xOffset, self.y + yOffset, self.height / 2)
end

function Slider:draw()
	love.graphics.setColor(50,50,50)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	self:drawHandle()
end

return Slider