local Entity = require("entities.entity")
local util = require("util")

local Player = Entity:extend()

local speed = 500

function Player:new(map, world, x, y, width, height)
    Player.super.new(self, world, x, y, width, height)
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
end

function Player:draw()
    local x, y = self:getCenter()
    util.drawFilledCircle(x, y, self.width / 2, 38, 166, 91)
end

return Player