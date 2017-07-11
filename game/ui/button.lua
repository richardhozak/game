local requiredir = (...):match("(.-)[^%.]+$")
local function requireitem(item) return require(requiredir .. item) end

local util = requireitem("util")
local Item = requireitem("item")

local Button = Item:extend("button")
function Button:new()
	self.super.new(self)
	self.width = self.width or 100
	self.height = self.height or 50
	self.radius = self.radius or 0
	self.color = self.color or function(self) 
		                           return self.pressed and {255,255,255,100} or self.mouseover and {20,20,20} or {255,255,255}
		                       end

	if self.border then
		self.border.width = self.border.width or 0
		self.border.color = self.border.color or {0,0,0,0}
	else
		self.border = {
            width=1,
            color={123,123,123}
        }
	end

	self.pressed = false
	self.mouseover = false
	self.down = false

	self.bindings = self:createBindings()
end

function Button:mousePressed(x, y, button, istouch)
	if self.super.mousePressed(self, x, y, button, istouch) then
		return true
	end

	Item.hotitem = self
	self.down = true
    return true
end

function Button:mouseReleased(x, y, button, istouch)
	if not self.enabled then return false end
	
	if self.down then
		self.down = false
		return true
	end

	return self.super.mousePressed(self, x, y, button, istouch)
end

function Button:update()
	self:evaluateBindings(self.bindings)

	if self.down then
		if self.mouseover then
			if not self.pressed then
				self.pressed = true
				util.emit(self.onPressed)
			end
		end
	else
		if self.pressed then
			self.pressed = false
			if self.mouseover then
				util.emit(self.onReleased)
				util.emit(self.onClicked)
			else
				util.emit(self.onCanceled)
			end
		end
	end

	self.super.update(self)
end

function Button:draw()
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.radius)
	
	if self.border then
		love.graphics.setColor(self.border.color)
		love.graphics.setLineWidth(self.border.width)
		love.graphics.rectangle("line", self.x, self.y, self.width, self.height, self.radius)
	end

	if self.text then
		local font = love.graphics.getFont()
		local xOffset = (self.width - font:getWidth(self.text.value)) / 2
		local yOffset = (self.height - font:getHeight()) / 2
		love.graphics.setColor(self.text.color)
		love.graphics.print(self.text.value, math.floor(self.x + xOffset), math.floor(self.y + yOffset))
	end
end

return Button