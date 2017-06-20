local Camera = require("camera")
local Map = require("map")

local Object = require("lib.classic")
local Game = Object:extend()

local debugInfo = [[
x: %f
y: %f
w: %f
h: %f
]]

function Game:new()
    self.camera = Camera()
    self.map = nil
    self.editing = false
    self.tileSize = 32
    --self:edit("test.lua")
end

function Game:update(dt)
    if self.map then self.map:update(dt) end
    self.camera:update(dt)
end

function Game:drawCheckerBoard(x, y, w, h, tileSize)
    local beginX = math.floor(x / tileSize) * tileSize
    local beginY = math.floor(y / tileSize) * tileSize
    local horizontalCount = math.ceil(w / tileSize) + 1
    local verticalCount = math.ceil(h / tileSize) + 1
    local xEven = math.floor(x / tileSize) % 2 == 0
    local yEven = math.floor(y / tileSize) % 2 == 0
    local evenOffset = (xEven and 1 or 0) + (yEven and 1 or 0)

    love.graphics.push()
    love.graphics.translate(beginX, beginY)
    for i=1, horizontalCount do
        for j=1, verticalCount do
            local x = (i-1)*tileSize
            local y = (j-1)*tileSize
            local isEven = ((i + j + evenOffset) % 2 == 0)
            local color = isEven and {52,52,52} or {65,65,65}
            love.graphics.setColor(color)
            love.graphics.rectangle("fill", x, y, tileSize, tileSize)
        end
    end
    love.graphics.pop()
end

function Game:drawMinimap(x, y, w, h, map, camera, scale)
    local scale = scale > 0 and camera.scale * scale or camera.scale
    love.graphics.setScissor(x, y, w, h)
    love.graphics.setColor(0,0,0,50)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(0,0,0,100)
    love.graphics.rectangle("line", x, y, w, h)

    local cameraWidth = camera.scaledWidth / scale
    local cameraHeight = camera.scaledHeight / scale
    local cameraX = (x+w/2)-cameraWidth/2
    local cameraY = (y+h/2)-cameraHeight/2

    love.graphics.push()
    love.graphics.translate(cameraX, cameraY)
    love.graphics.scale(1 / scale, 1 / scale)
    love.graphics.translate(-camera.x, -camera.y)

    map:draw()

    love.graphics.pop()

    love.graphics.setColor(255,255,255)
    love.graphics.rectangle("line", cameraX, cameraY, cameraWidth, cameraHeight)

    love.graphics.setScissor()
end

function Game:draw()
    self.camera:draw(function(x, y, w, h)
        if self.editing and self.map then 
            self:drawCheckerBoard(x, y, w, h, self.map.tileSize)
        end
        if self.map then 
            self.map:draw()
        end
    end)

    if self.editing and self.map then 
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local minimapWidth, minimapHeight = 200, 200
        local minimapX, minimapY = screenWidth - minimapWidth, screenHeight - minimapHeight
        self:drawMinimap(minimapX, minimapY, minimapWidth, minimapHeight, self.map, self.camera, 10) 
    end
    love.graphics.setColor(255,255,255)
    love.graphics.print(string.format(debugInfo, self.camera.x, self.camera.y, self.camera.width, self.camera.height))
end

function Game:reset()

end

function Game:editLevel(level)
    if not level then
        return
    end
    local mapfunction, errormsg = love.filesystem.load("maps/".. level)
    if errormsg then
        error("could not load map", level)
    else
        print("loading", level)
        self.editing = true
        self.map = Map(mapfunction(), self.camera)
        self.camera:setBounds()
    end
end

function Game:saveLevel(level)
    if not level or not self.editing then
        return
    end
end

function Game:loadGame(level)
    if not level then
        return
    end
    local mapfunction, errormsg = love.filesystem.load("saves/"..level)
    if errormsg then
        error("could not load map", level)
    else
        print("loading", level)
        self.map = Map(mapfunction(), self.camera)
    end
end

function Game:saveGame(level)

end

function Game:keyPressed(key, scancode, isrepeat)
    
end

function Game:keyReleased(key, scancode)
    
end

function Game:mousePressed(x, y, button, istouch)

end

function Game:mouseReleased(x, y, button, istouch)

end

function Game:mouseMoved(x, y, dx, dy, istouch)
    if not self.camera.lockOn and self.map and love.mouse.isDown(2) then
        self.camera:move(-dx, -dy)
    end
end

function Game:textInput(text)

end

function Game:wheelMoved(x, y)
    if not self.camera.lockOn then
        self.camera:setScale(self.camera.scale - y)
    end
end

return Game