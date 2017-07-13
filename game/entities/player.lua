local util = require("util")

local Bullet = require("entities.bullet")
local Weapon = require("entities.weapon")
local Entity = require("entities.entity")
local Enemy = require("entities.enemy")

local Player = Entity:extend()

local speed = 300

function Player:new(map, world, camera, x, y, width, height)
    Player.super.new(self, world, x, y, width, height)
    self.camera = camera
    self.weapon = Weapon(self, self.world, self.camera)
    self.horizontal = 0
    self.vertical = 0
end

function Player:collisionFilter(other)
    if other:is(Bullet) then
        return "cross"
    elseif other:is(Enemy) then
        if other.isDead then
            return "cross"
        else
            return "slide"
        end
    else
        return "slide"
    end
end

function Player:update(dt)
    if self.vertical ~= 0 or self.horizontal ~= 0 then
        local x = self.x
        local y = self.y
        y = y + self.vertical * speed * dt 
        x = x + self.horizontal * speed * dt

        local x, y, cols, len = self.world:move(self, x, y, self.collisionFilter)
        self.x, self.y = x, y
    end

    self.weapon:update(dt)
end

function Player:draw()
    local x, y = self:getCenter()
    util.drawFilledCircle(x, y, self.width / 2, 38, 166, 91)
    self.weapon:draw()
end

function Player:keypressed(key, scancode, isrepeat)
    if key == "w" then
        self.vertical = self.vertical - 1
    end

    if key == "s" then
        self.vertical = self.vertical + 1
    end

    if key == "a" then
        self.horizontal = self.horizontal - 1
    end

    if key == "d" then
        self.horizontal = self.horizontal + 1
    end
end

function Player:keyreleased(key, scancode)
    if key == "w" then
        self.vertical = self.vertical + 1
    end

    if key == "s" then
        self.vertical = self.vertical - 1
    end 

    if key == "a" then
        self.horizontal = self.horizontal + 1
    end

    if key == "d" then
        self.horizontal = self.horizontal - 1
    end
end

function Player:mousepressed(button)
    self.weapon:mousepressed(button)
end

function Player:mousereleased(button)
    self.weapon:mousereleased(button)
end

function Player:hit()
    print("hit")
end

return Player