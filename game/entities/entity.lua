local Object = require("lib.classic")
local Entity = Object:extend()

function Entity:new(world, x, y, width, height)
    self.world = world
    self.x, self.y, self.width, self.height = x, y, width, height
    self.world:add(self, x, y, width, height)
    self.createdAt = love.timer.getTime()
end

function Entity:update(dt)
end

function Entity:draw()
end

function Entity:destroy()
    self.world:remove(self)
end

function Entity:getCenter()
    return self.x + self.width / 2, 
           self.y + self.height / 2
end

return Entity