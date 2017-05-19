Object = require("classic")
Timer = require("hump.enhancedtimer")

Rectangle = Object:extend()

function Rectangle:new()
	self.timer = Timer()
	self.max_width = 400
	self.min_width = 200
	self.width = 200
	self.down = false
	--self.timer:tween(4, self, {width = 400}, "linear")
end

function Rectangle:update(dt)
	self.timer:update(dt)

	local button_down = input:down("right") or input:down("left") or input:down("up") or input:down("down")
	local max_travel = self.max_width - self.min_width
	local travelled = self.width - self.min_width
	local percentage = travelled / max_travel

	if button_down and not self.down then
		self.down = true
		local duration = 4 * (1 - percentage)
		self.timer:tween("run", duration, self, {width = self.max_width}, "out-quint")
	end

	if not button_down and self.down then
		self.down = false
		print("released")
		local duration = 4 * percentage
		self.timer:tween("run", duration, self, {width = self.min_width}, "out-quint")
	end
end

function Rectangle:draw()
	--love.graphics.setColor()
	love.graphics.rectangle("fill", 0, 0, self.width, 100)
end