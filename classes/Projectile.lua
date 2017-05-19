Object = require("classic")

Projectile = Object:extend()

function Projectile:new(x, y, rotation, distance_offset, speed)
	self.origin_x = x
	self.origin_y = y
	self.rotation = rotation
	self.distance = distance_offset or 0
	self.x = x
	self.y = y
	self.speed = speed or 50
end

function Projectile:update(dt)
	self.distance = self.distance + self.speed * dt
	self.x = self.distance * math.cos(self.rotation) + self.origin_x
	self.y = self.distance * math.sin(self.rotation) + self.origin_y
end

function Projectile:draw()
	love.graphics.setColor(174,168,211,255)
	love.graphics.push()
	love.graphics.translate(self.origin_x, self.origin_y)
	love.graphics.rotate(self.rotation)
	love.graphics.rectangle("fill", self.distance, -2, 10, 4)
	love.graphics.pop()
end