inspect = require("lib.inspect")

local Game = require("game")
local nui = require("newnewui")
local files = {
    "one",
    "two",
    --"three",
    --"four"
}

function love.load()
    love.window.setMode(800, 600, {x=1119, y=25, resizable=true})

    column = nui.column {
        x=10,y=10,
        spacing=10,
        {
            nui.button {
                width=100,
                height=50,
                color={200,200,200,200}
            },
            nui.button {
                width=100,
                height=50,
                color={200,200,200,200}
            },
            nui.button {
                width=100,
                height=50,
                color={200,200,200,200}
            },
            nui.button {
                width=100,
                height=50,
                color={200,200,200,200}
            }
        }
    }
    
    print(inspect(column))
    column()
end

function love.update(dt)
    column()
end

function love.draw()
    nui.drawItem(column)
    love.graphics.setColor(255,255,255)
    love.graphics.rectangle("line", column.x, column.y, column.width, column.height)
end

--[[
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
--]]
