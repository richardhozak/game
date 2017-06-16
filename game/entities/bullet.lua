local util = require("util")

local Entity = require("entities.entity")
local Bullet = Entity:extend()

function Bullet:new(world, weapon, width, height)
	self.weapon = weapon
	self.rotation = self.weapon.rotation
	local muzzleOffset = 10
	local offset = self.weapon.offset + self.weapon.width + width/2 + muzzleOffset
	local cornerX = self.weapon.x - width/2
	local cornerY = self.weapon.y - height/2
	local x = cornerX + math.cos(self.rotation) * offset
	local y = cornerY + math.sin(self.rotation) * offset
	self.speed = 100
	Bullet.super.new(self, world, x, y, width, height)
end

local function bulletFilter(item, other)
	if type(other.hit) == "function" then
		return "cross"
	else
		return "slide"
	end
end

function Bullet:update(dt)
	local newX = self.x + math.cos(self.rotation) * self.speed * dt
	local newY = self.y + math.sin(self.rotation) * self.speed * dt

	local x, y, cols, len = self.world:move(self, newX, newY, bulletFilter)
	if len > 0 then
		for i=1, len do
			local other = cols[i].other
			if type(other.hit) == "function" then
				other:hit()
			end
		end
		self:destroy()
	end
    self.x, self.y = x, y
end

function Bullet:draw()
	local cx, cy = self:getCenter()

	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	love.graphics.push()
	love.graphics.translate(cx, cy)
	love.graphics.rotate(self.rotation)
	util.drawFilledRectangle(-self.width/2, -self.height/2, self.width, self.height, 102,51,153)
	love.graphics.setColor(123,123,123,255)
	
	love.graphics.pop()
	
	
	--util.drawFilledCircle(cx, cy, self.width/2, 217, 30, 24)
end

return Bullet