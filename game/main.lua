local camera = require("camera")
local lovebird = require("lib.lovebird")
local lurker = require("lib.lurker")
local Map = require("map")
local Dialog = require("ui.dialog")
local ui = require("ui.ui")

local map, dialog

function love.load()
    love.window.setMode(800, 600, {x=1120, y=25})
    
    timer = require("hump.enhancedtimer")()
    map = Map(2000, 1000)
    camera:setRegion(0, 0, map.width, map.height)

    local width, height = love.graphics.getDimensions()
end

function love.update(dt)
    lurker.update()
    lovebird.update()
    
    if not ui.isPaused then
        map:update(dt)
        timer:update(dt)
        camera:update(dt)
        camera:setPosition(map.player:getCenter())
    end

    ui:update(dt)
end

function love.draw()
    camera:draw(function(x,y,w,h) 
        map:draw(x,y,w,h)
    end)

    local width, height = love.graphics.getDimensions()

    ui:draw(0, 0, width, height)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        ui.isPaused = not ui.isPaused
    end
end
