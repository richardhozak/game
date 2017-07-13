inspect = require("lib.inspect")
local opts = {process=function(item, path) 
        if path[#path] ~= inspect.METATABLE and path[#path] ~= "parent" then return item end
    end}
pprint = function(t) print(inspect(t, opts)) end

local Game = require("game")
local game
local flux = require("lib.flux")

function love.load()
    io.stdout:setvbuf("no")
    local crosshair = love.mouse.newCursor("cross.png", 10, 10)
    love.mouse.setCursor(crosshair)

    love.graphics.setFont(love.graphics.newFont("fonts/OpenSans-Light.ttf", 13))

    love.window.setMode(800, 600, {x=1119, y=25, resizable=true})
    -- love.window.setMode(800, 600, {x=2100, y=1000, resizable=true})
    game = Game()
end

function love.update(dt)
    flux.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(key, scancode, isrepeat)
    game:keyPressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    game:keyReleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch)
    game:mousePressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    game:mouseReleased(x, y, button, istouch)
end

function love.mousemoved(x, y, dx, dy, istouch)
    game:mouseMoved(x, y, dx, dy, istouch)
end

function love.textinput(text)
    game:textInput(text)
end

function love.wheelmoved(x, y)
    game:wheelMoved(x, y)
end
