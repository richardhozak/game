local Object = require("lib.classic")
local bump = require("lib.bump")
local Player = require("entities.player")
local Block = require("entities.block")

local Map = Object:extend()

function Map:new(map, width, height)
    self.map = map
    self.tileSize = 50
    if self.map then
        self.x, self.y = self.map.x*self.tileSize, self.map.y*self.tileSize
        self.width, self.height = self.map.width*self.tileSize, self.map.height*self.tileSize
    else
        self.x, self.y = 0
        self.width, self.height = width, height
    end
    self:reset()
end

function Map:reset()
    if not self.map then
        self:loadDefault()
        return
    end
    
    print("resetting map")
    self.world = bump.newWorld(50)
    self.player = nil

    for index,item in ipairs(self.map.items) do
        if item.tile == 5 and not self.player then
            self.player = Player(self, self.world, item.x*self.tileSize, item.y*self.tileSize, 32, 32)
        else
            if item.tile ~= 4 then
                Block(self.world, item.x*self.tileSize, item.y*self.tileSize, self.tileSize, self.tileSize)
            end
        end
    end
end

function Map:loadDefault()
    self.world = bump.newWorld()
    self.player = Player(self, self.world, 60, 60, 32, 32)

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