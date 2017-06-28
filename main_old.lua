local camera = require("camera")
local lovebird = require("lib.lovebird")
local lurker = require("lib.lurker")
local Map = require("map")
local Dialog = require("ui.dialog")
local ui = require("ui.ui")
local Editor = require("editor")
local nk = require("nuklear")

local map, dialog
local editor
local menu

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
        menu = "game"
    end
end

function love.load()
    love.window.setMode(800, 600, {x=1119, y=25, resizable=true})
    
    timer = require("hump.enhancedtimer")()
    ui:setLoadLevelCallback(loadLevel)
    ui:setEnterEditorCallback(enterEditor)
    editor = Editor(camera)
    nk.init()
    menu = "main"
    print(nk.inputIsHovered)
    print(nk.isKeyPressed)
end

local function updateLevelUi()
    local width, height = love.graphics.getDimensions()
    local menuWidth, menuHeight = 200, 400
    local menuYOffset = 50
    local menuXOffset = (width-menuWidth)/2

    if nk.windowBegin("Levels", menuXOffset, menuYOffset, menuWidth, menuHeight, "title", "scrollbar") then
        nk.layoutRow("dynamic", 35, 1)
        local files = love.filesystem.getDirectoryItems("maps")
        for index, file in ipairs(files) do
            if nk.button(file) then
                loadLevel(file)
            end
        end

        if nk.button("Back") then
            menu = "main"
        end
    end
    nk.windowEnd()
end

local function updateMainMenuUi()
    local width, height = love.graphics.getDimensions()
    local menuWidth, menuHeight = 200, 400
    local menuYOffset = 50
    local menuXOffset = (width-menuWidth)/2

    if nk.windowBegin("Menu", menuXOffset, menuYOffset, menuWidth, menuHeight, "title") and menu == "main" then
        nk.layoutRow("dynamic", 35, 1)
        if nk.button("Editor") then
            editor:reset()
            menu = "editor"
        end
        if nk.button("Load level") then
            menu = "levels"
        end
        if nk.button("Exit") then
            love.event.quit()
        end
    end
    nk.windowEnd()
end

function love.update(dt)
    lurker.update()
    lovebird.update()

    camera.followPlayer = menu ~= "editor"

    if menu == "editor" then
        if editor:update(dt) then
            camera:update(dt)
        end
    else
        if map then
            if menu == "game" then
                map:update(dt)
                timer:update(dt)
                camera:update(dt)
                camera:setPosition(map.player:getCenter())
            end
        end
    end

    nk.frameBegin()
        if menu == "main" then
            updateMainMenuUi()            
        elseif menu == "levels" then
            updateLevelUi()
        elseif menu == "editor" then
            editor:updateUi()
        elseif map then
            local uimenu = map:updateUi()
            if uimenu then
                menu = uimenu
            end
        end
    nk.frameEnd()
end

function love.draw()
    if menu == "editor" then
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
    end

    nk.draw()
end

function love.keypressed(key, scancode, isrepeat)
    if nk.keypressed(key, scancode, isrepeat) then
        return
    end

    if editor then
        editor:keyPressed(key, scancode)
    end

    if map then
        map:keypressed(key, scancode, isrepeat)
    end
end

function love.keyreleased(key, scancode)
    if nk.keyreleased(key, scancode) then
        return
    end

    if editor then
        editor:keyReleased(key, scancode)
    end

    if map then
        map:keyreleased(key, scancode)
    end
end

function love.mousepressed(x, y, button, istouch)
    if nk.mousepressed(x, y, button, istouch) then
        return
    end

    if editor then
        editor:mousePressed(x, y, button)
    end

    if map then
        map:mousepressed(x, y, button, istouch)
    end
end

function love.mousereleased(x, y, button, istouch)
    if nk.mousereleased(x, y, button, istouch) then
        return
    end

    if editor then
        editor:mouseReleased(x, y, button)
    end
    
    if map then
        map:mousereleased(x, y, button, istouch)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if nk.mousemoved(x, y, dx, dy, istouch) then
        return
    end
end

function love.textinput(text)
    if nk.textinput(text) then
        return 
    end
end

function love.wheelmoved(x, y)
    if nk.wheelmoved(x, y) then
        return
    end

    if editor then
        editor:wheelMoved(x, y)
    end
end
