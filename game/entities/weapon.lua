local lume = require("lib.lume")
local Bullet = require("entities.bullet")

local Object = require("lib.classic")
local Weapon = Object:extend()

function Weapon:new(player, world, camera)
	self.world = world
	self.player = player
	self.camera = camera
	self.x, self.y = 0, 0
	self.width = 20
	self.height = 10
	self.rotation = 0
	self.offset = self.player.width / 2 - 10
	self.timeShotTimer = 0
	self.timeBetweenShots = 4 * 1000
	self.shooting = false
end

function Weapon:update(dt)
	self.x, self.y = self.player:getCenter()

	local mouseX, mouseY = self.camera:getMousePosition()
	local deltaX = mouseX - self.x
	local deltaY = mouseY - self.y

	self.rotation = math.atan2(deltaY, deltaX)

	if self.shooting and self.timeShotTimer <= 0 then
		self.timeShotTimer = self.timeBetweenShots
		self:fire()
	end

	if self.timeShotTimer > 0 then
		self.timeShotTimer = self.timeShotTimer - love.timer.getTime()*dt
	end
end

function Weapon:draw()
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	love.graphics.rotate(self.rotation)
	love.graphics.translate(self.offset, -(self.height/2))
	love.graphics.rectangle("fill", 0, 0, self.width, self.height)
	love.graphics.pop()
end

function Weapon:mousepressed(button)
    if button == 1 then
        self.shooting = true
    end
end

function Weapon:mousereleased(button)
    if button == 1 then
        self.shooting = false
    end
end

function Weapon:fire()
	Bullet(self.world, self, 10, 10)
end

return Weapon