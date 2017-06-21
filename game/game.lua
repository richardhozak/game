local Camera = require("camera")
local Level = require("level")
local Editor = require("editor")
local luatable = require("lib.LuaTable")
local bitser = require("lib.bitser")

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
    --self.editor = Editor(self.camera)
    self.map = nil
    self.editing = false
    self.tileSize = 32
    --self:edit("test.lua")
    self:loadLevel("bitmap")
end

function Game:update(dt)
    if self.editing then
        self.editor:update(dt)
    elseif self.level then 
        self.level:update(dt) 
    end

    self.camera:update(dt)
end

function Game:draw()
    self.camera:draw(function(x, y, w, h)
        if self.editing then 
            self.editor:draw(x, y, w, h)
        elseif self.level then 
            self.level:draw()
        end
    end)

    if self.editing then
        self.editor:drawUi()
    end

    --[[
    if self.editing and self.map then 
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local minimapWidth, minimapHeight = 200, 200
        local minimapX, minimapY = screenWidth - minimapWidth, screenHeight - minimapHeight
        self.map:drawMinimap(minimapX, minimapY, minimapWidth, minimapHeight, self.camera, 10) 
    end
    --]]

    self:drawDebugInfo()
end

function Game:drawDebugInfo()
    love.graphics.setColor(255,255,255)
    love.graphics.print(string.format(debugInfo, self.camera.x, self.camera.y, self.camera.width, self.camera.height))
end

function Game:updateLevelAndSave(level)
    local mapfunction, errormsg = love.filesystem.load("maps/" .. level)
    if errormsg then
        error("could not load map", level)
    else
        print("loading", level)
        local map = mapfunction()
        map = self:updateMapVersion(map)
        map = luatable.encode_pretty(map)
        love.filesystem.write("maps/" .. level, map)
    end
end

function Game:updateMapVersion(map)
    if map.version == 1 then
        local newItems = {}
        for i=1, #map.items do
            local item = map.items[i]
            local x, y, tile = item.x, item.y, item.tile
            if newItems[x] == nil then
                newItems[x] = {}
            end

            newItems[x][y] = tile
        end
        map.items = newItems
        map.version = 2
        return map
    elseif map.version == 2 then
        return map
    else
        error("invalid map")
    end
end

function Game:editLevel(name)
    self.map = bitser.loadLoveFile("maps/" .. name)
    self.camera:setBounds()
    self.editing = true
end

function Game:loadLevel(name)
    self.map = bitser.loadLoveFile("maps/" .. name)
    self.level = Level(self.map, self.camera)
    self.editing = false
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
    local mapfunction, errormsg = love.filesystem.load("saves/" .. level)
    if errormsg then
        error("could not load map", level)
    else
        print("loading", level)
        self.map = mapfunction()
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