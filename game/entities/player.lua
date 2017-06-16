local util = require("util")

local Weapon = require("entities.weapon")
local Entity = require("entities.entity")

local Player = Entity:extend()

local speed = 300

function Player:new(map, world, camera, x, y, width, height)
    Player.super.new(self, world, x, y, width, height)
    self.camera = camera
    self.weapon = Weapon(self, self.world, self.camera)
end

function Player:update(dt)
    local x = self.x
    local y = self.y
    if love.keyboard.isDown("w") then
        y = y - speed * dt
    end

    if love.keyboard.isDown("s") then
        y = y + speed * dt
    end

    if love.keyboard.isDown("a") then
        x = x - speed * dt
    end

    if love.keyboard.isDown("d") then
        x = x + speed * dt
    end

    local x, y, cols, len = self.world:move(self, x, y)

    self.x, self.y = x, y

    self.weapon:update(dt)
end

function Player:draw()
    local x, y = self:getCenter()
    util.drawFilledCircle(x, y, self.width / 2, 38, 166, 91)
    self.weapon:draw()
end

function Player:hit()
    print("hit")
end

return Player