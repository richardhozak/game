local camera = require("camera")

local Editor = require("editor")

local editor
local cameraX, cameraY

function love.load()
    love.window.setMode(800, 600, {x=1120, 
                                   y=25, 
                                   resizable=true, 
                                   minwidth=640, 
                                   minheight=480})

    editor = Editor(camera)
end

function love.update(dt)
    if editor:update(dt) then
        camera:update(dt)
    end
end

function love.draw()
    camera:draw(function(x,y,w,h)
        editor:draw(x, y, w, h)
    end)

    editor:drawUi()
end

function love.wheelmoved(x, y)
    editor:wheelMoved(x, y)
end

function love.mousepressed(x, y, button, istouch)
    editor:mousePressed(x, y, button)
end

function love.mousereleased(x, y, button, istouch)
    editor:mouseReleased(x, y, button)
end

function love.keypressed(key, scancode, isrepeat)
    editor:keyPressed(key, scancode)
end


function love.keyreleased(key, scancode)
    editor:keyReleased(key, scancode)
end