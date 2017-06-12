local Entity = require("entities.entity")
local Block = Entity:extend()

local util = require("util")

function Block:new(world, x, y, width, height)
    Block.super.new(self, world, x, y, width, height)
end

function Block:draw()
    util.drawFilledRectangle(self.x, self.y, self.width, self.height, 31, 58, 147)
end

return Block