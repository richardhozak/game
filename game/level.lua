local Object = require("lib.classic")
local bump = require("lib.bump")
local Player = require("entities.player")
local Block = require("entities.block")
local Enemy = require("entities.enemy")

local Level = Object:extend()

function Level:new(map, camera)
    self.map = map
    self.camera = camera
    self.paused = false
    self:reset()
end

function Level:reset()
    print("resetting map")
    self.tileSize = 50
    self.x, self.y = self.map.x*self.tileSize, self.map.y*self.tileSize
    self.width, self.height = self.map.width*self.tileSize, self.map.height*self.tileSize
    self.world = bump.newWorld(50)
    self.player = nil

    for x, row in pairs(self.map.items) do
        for y, tile in pairs(row) do
            local finalX = x*self.tileSize
            local finalY = y*self.tileSize

            if tile == 5 and not self.player then
                self.player = Player(self, self.world, self.camera, finalX, finalY, 32, 32)
            elseif tile == 8 then
                Enemy(self.world, x, y, finalX, finalY, self.tileSize, self.tileSize, self.map, self.tileSize)
            elseif tile ~= 4 and tile ~= 9 then
                Block(self.world, finalX, finalY, self.tileSize, self.tileSize)
            end
        end
    end

    self.camera:setBounds(self.x, self.y, self.width, self.height)
end

function Level:loadDefault()
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

function Level:update(dt, x, y, width, height)
    if self.paused then
        return
    end

    local items, len = self.world:getItems()
    for i=1, len do
        items[i]:update(dt)
    end
end

function Level:draw()
    local items, len = self.world:getItems()
    for i=1, len do
        items[i]:draw()
    end
end

function Level:drawCheckerBoard(x, y, w, h)
    local beginX = math.floor(x / self.tileSize) * self.tileSize
    local beginY = math.floor(y / self.tileSize) * self.tileSize
    local horizontalCount = math.ceil(w / self.tileSize) + 1
    local verticalCount = math.ceil(h / self.tileSize) + 1
    local xEven = math.floor(x / self.tileSize) % 2 == 0
    local yEven = math.floor(y / self.tileSize) % 2 == 0
    local evenOffset = (xEven and 1 or 0) + (yEven and 1 or 0)

    love.graphics.push()
    love.graphics.translate(beginX, beginY)
    for i=1, horizontalCount do
        for j=1, verticalCount do
            local x = (i-1)*self.tileSize
            local y = (j-1)*self.tileSize
            local isEven = ((i + j + evenOffset) % 2 == 0)
            local color = isEven and {52,52,52} or {65,65,65}
            love.graphics.setColor(color)
            love.graphics.rectangle("fill", x, y, self.tileSize, self.tileSize)
        end
    end
    love.graphics.pop()
end

function Level:drawMinimap(x, y, w, h, scale)
    local scale = scale > 0 and self.camera.scale * scale or self.camera.scale
    love.graphics.setScissor(x, y, w, h)
    love.graphics.setColor(0,0,0,50)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(0,0,0,100)
    love.graphics.rectangle("line", x, y, w, h)

    local cameraWidth = self.camera.scaledWidth / scale
    local cameraHeight = self.camera.scaledHeight / scale
    local cameraX = (x+w/2)-cameraWidth/2
    local cameraY = (y+h/2)-cameraHeight/2

    love.graphics.push()
    love.graphics.translate(cameraX, cameraY)
    love.graphics.scale(1 / scale, 1 / scale)
    love.graphics.translate(-self.camera.x, -self.camera.y)

    self:draw()

    love.graphics.pop()

    love.graphics.setColor(255,255,255)
    love.graphics.rectangle("line", cameraX, cameraY, cameraWidth, cameraHeight)

    love.graphics.setScissor()
end

function Level:updateUi()
    if self.paused then
        local width, height = love.graphics.getDimensions()
        local windowWidth = 200
        local windowHeight = 140
        local windowOffsetY = 50
        local windowOffsetX = (width-windowWidth)/2

        --[[
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
        ]]
    end
end

function Level:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        self.paused = not self.paused
        return
    end

    self.player:keypressed(key, scancode, isrepeat)
end

function Level:keyreleased(key, scancode)
    self.player:keyreleased(key, scancode)
end

function Level:mousepressed(x, y, button, istouch)
    self.player:mousepressed(button)
end

function Level:mousereleased(x, y, button, istouch)
    self.player:mousereleased(button)
end

return Level