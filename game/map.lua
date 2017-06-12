local Object = require("lib.classic")
local bump = require("lib.bump")
local Player = require("entities.player")
local Block = require("entities.block")

local Map = Object:extend()

function Map:new(width, height)
    self.width, self.height = width, height
    self:reset()
end

function Map:reset()
    self.world = bump.newWorld()
    self.player = Player(self, self.world, 60, 60)

    Block(self.world, 0, 0, self.width, 50) -- top
    Block(self.world, 0, 50, 50, self.height - 100) -- left
    Block(self.world, 0, self.height - 50, self.width, 50) -- bottom
    Block(self.world, self.width - 50, 50, 50, self.height - 100) -- right

    --center cross
    local height = 500
    local width = 50
    Block(self.world, self.width / 2 - width / 2, (self.height - height) / 2, 50, height) -- vertical
    Block(self.world, (self.width - height) / 2, self.height / 2 - width / 2, height, 50) -- horizontal

    local xOffset = 200
    local yOffset = 200

    Block(self.world, xOffset, yOffset, 500, 50)
    Block(self.world, xOffset, self.height - yOffset - 50, 500, 50)
    Block(self.world, self.width - xOffset - 500, yOffset, 500, 50)
    Block(self.world, self.width - xOffset - 500, self.height - yOffset - 50, 500, 50)
end

function Map:update(dt, x, y, width, height)
    local items, len = self.world:getItems()
    for i=1, len do
        items[i]:update(dt)
    end
end

function Map:draw(x, y, width, height)
    local items, len = self.world:getItems()
    for i=1, len do
        items[i]:draw()
    end
end

return Map