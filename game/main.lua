local camera = require("camera")
local lovebird = require("lib.lovebird")
local lurker = require("lib.lurker")
local Map = require("map")
local Dialog = require("ui.dialog")
local ui = require("ui.ui")
local Editor = require("editor")

local map, dialog
local editor
local editorEnabled

local function loadLevel(levelname)
    if not levelname then
        map = nil
        camera:setRegion(0,0,0,0)
        return
    end
    local mapfunction, errormsg = love.filesystem.load("maps/"..levelname)
    if errormsg then
        error("could not load map", levelname)
    else
        print("loading", levelname)
        map = Map(mapfunction(), camera)
        ui.state = "none"
    end
end

local function enterEditor()
    editor:reset()
    editorEnabled = true
end

function love.load()
    love.window.setMode(800, 600, {x=1120, y=25, resizable=true})
    
    timer = require("hump.enhancedtimer")()
    ui:setLoadLevelCallback(loadLevel)
    ui:setEnterEditorCallback(enterEditor)
    editor = Editor(camera)
end

function love.update(dt)
    lurker.update()
    lovebird.update()

    camera.followPlayer = not editorEnabled

    if editorEnabled then
        if editor:update(dt) then
            camera:update(dt)
        end
    else
        if map then
            if not ui:getPaused() then
                map:update(dt)
                timer:update(dt)
                camera:update(dt)
                camera:setPosition(map.player:getCenter())
            end
        end
        ui:update(dt)
    end
end

function love.draw()
    if editorEnabled then
        camera:draw(function(x,y,w,h)
            editor:draw(x, y, w, h)
        end)

        editor:drawUi()
    else
        if map then
            camera:draw(function(x,y,w,h) 
                map:draw(x,y,w,h)
            end)
        end
        local width, height = love.graphics.getDimensions()
        ui:draw(0, 0, width, height)
    end
end

function love.wheelmoved(x, y)
    if editorEnabled then
        editor:wheelMoved(x, y)
    end
end

function love.mousepressed(x, y, button, istouch)
    if editorEnabled then
        editor:mousePressed(x, y, button)
    end
end

function love.mousereleased(x, y, button, istouch)
    if editorEnabled then
        editor:mouseReleased(x, y, button)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if editorEnabled then
        if key == "escape" then
            editorEnabled = false
        else
            editor:keyPressed(key, scancode)
        end
    else
        if key == "r" and ui.state == "main" then
            love.event.quit("restart")
        elseif key == "escape" then
            ui:pauseResume()
        end
    end
end


function love.keyreleased(key, scancode)
    if editorEnabled then
        editor:keyReleased(key, scancode)
    end
end
