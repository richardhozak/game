local Object = require("lib.classic")
local bump = require("lib.bump")
local Player = require("entities.player")
local Block = require("entities.block")

local nk = require("nuklear")

local Map = Object:extend()

function Map:new(map, camera)
    self.map = map
    self.tileSize = 50
    self.x, self.y = self.map.x*self.tileSize, self.map.y*self.tileSize
    self.width, self.height = self.map.width*self.tileSize, self.map.height*self.tileSize
    self.camera = camera
    self.paused = false
    self:reset()
end

function Map:reset()
    print("resetting map")
    self.world = bump.newWorld(50)
    self.player = nil

    for index,item in ipairs(self.map.items) do
        if item.tile == 5 and not self.player then
            self.player = Player(self, self.world, self.camera, item.x*self.tileSize, item.y*self.tileSize, 32, 32)
        else
            if item.tile ~= 4 then
                Block(self.world, item.x*self.tileSize, item.y*self.tileSize, self.tileSize, self.tileSize)
            end
        end
    end

    self.camera:setRegion(self.x, self.y, self.width, self.height)
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
    if self.paused then
        return
    end

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

function Map:updateUi()
    if self.paused then
        local width, height = love.graphics.getDimensions()
        local windowWidth = 200
        local windowHeight = 140
        local windowOffsetY = 50
        local windowOffsetX = (width-windowWidth)/2

        if nk.windowBegin("Pause", windowOffsetX, windowOffsetY, windowWidth, windowHeight, "title") then
            nk.layoutRow("dynamic", 35, 1)
            if nk.button("Resume") then
                self.paused = false
            end
            if nk.button("Main menu") then
                return "main"
            end
        end
        nk.windowEnd()
    end
end

function Map:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        self.paused = not self.paused
        return
    end

    self.player:keypressed(key, scancode, isrepeat)
end

function Map:keyreleased(key, scancode)
    self.player:keyreleased(key, scancode)
end

function Map:mousepressed(x, y, button, istouch)
    self.player:mousepressed(button)
end

function Map:mousereleased(x, y, button, istouch)
    self.player:mousereleased(button)
end

return Map