Object = require("classic")
Timer = require("hump.enhancedtimer")
Projectile = require("classes.Projectile")

Player = Object:extend()

local function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end

function Player:new(x, y)
	self.x = x
	self.y = y
	self.width = 50
	self.height = 50
	self.speed = 250
	self.acceleration = 0
	local window_width, window_height = love.graphics.getDimensions()
	self.max_x = window_width - self.width / 2
	self.max_y = window_height - self.height / 2
	self.min_x = self.width / 2
	self.min_y = self.height / 2
	self.down = false
	self.timer = Timer()
	self.acceleration_duration = 1
	self.deceleration_duration = 0.5
	self.angle = 0
	self.projectiles = {}

	dump(self, "")
end

function Player:update(dt)
	self.timer:update(dt)

	local button_down = input:down("right") or input:down("left") or input:down("up") or input:down("down")

	if button_down and not self.down then
		self.down = true
		local duration = self.acceleration_duration * (1 - self.acceleration)
		self.timer:tween("run", duration, self, {acceleration = 1}, "out-sine")
	end

	if not button_down and self.down then
		self.down = false
		local duration = self.deceleration_duration * self.acceleration
		self.timer:tween("run", duration, self, {acceleration = 0}, "out-sine", function() self.acceleration = 0 end )
	end

	if input:down("right") then
		self.x = self.x + self.speed * self.acceleration * dt
	end

	if input:down("left") then
		self.x = self.x - self.speed * self.acceleration * dt
	end

	if input:down("up") then
		self.y = self.y - self.speed * self.acceleration * dt
	end

	if input:down("down") then
		self.y = self.y + self.speed * self.acceleration * dt
	end

	self.y = clamp(self.min_y, self.y, self.max_y)
	self.x = clamp(self.min_x, self.x, self.max_x)

	local deltaY = love.mouse.getY() - self.y
	local deltaX = love.mouse.getX() - self.x

	self.angle = math.atan2(deltaY, deltaX)

	for i = #self.projectiles, 1, -1 do
		if self:outOfBounds(self.projectiles[i]) then
			table.remove(self.projectiles, i)
		end
	end

	if input:pressRepeat("shoot", 0.1) then
		table.insert(self.projectiles, Projectile(self.x, self.y, self.angle, 40, 500))
	end

	for i = 1, #self.projectiles, 1 do
		self.projectiles[i]:update(dt)
	end
end

function Player:outOfBounds(item)
	if not item then
		return false
	end
	return item.x < 0 or item.y < 0 or item.x > love.graphics.getWidth() or item.y > love.graphics.getHeight()
end

function Player:draw()
	love.graphics.setColor(150, 123, 123, 255)
	love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(#self.projectiles, self.x, self.y, 0, 1, 1, 0, 0)

	love.graphics.push()
	love.graphics.setColor(246,36,89,255)
	love.graphics.translate(self.x, self.y)
	love.graphics.rotate(self.angle)
	love.graphics.rectangle("fill", 0, 0 - 10, 40, 20)
	love.graphics.pop()

	for i = 1, #self.projectiles, 1 do
		self.projectiles[i]:draw()
	end
end