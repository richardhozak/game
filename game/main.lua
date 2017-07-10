inspect = require("lib.inspect")
local opts = {process=function(item, path) 
        if path[#path] ~= inspect.METATABLE and path[#path] ~= "parent" then return item end
    end}
pprint = function(t) print(inspect(t, opts)) end

local Game = require("game")
local ui = require("ui")
local game

local count = 2

local displayText = ""

function love.load()
    io.stdout:setvbuf("no")
    love.graphics.setFont(love.graphics.newFont("fonts/OpenSans-Light.ttf", 18))

    love.window.setMode(800, 600, {x=1119, y=25, resizable=true})
    game = Game()
end

function love.update(dt)
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
