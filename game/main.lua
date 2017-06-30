inspect = require("lib.inspect")

local Game = require("game")
local ui = require("ui")
local nui = require("newui")
local game

function love.load()
    io.stdout:setvbuf("no")
    

    -- love.window.setMode(800, 600, {x=1119, y=25, resizable=true})
    love.window.setMode(800, 600, {x=2100, y=800, resizable=true})
    print("game started")
    game = Game()
    button = nui.button {
        x=10,y=10,
        width=100,
        height=50,
        color={255,255,255}
    }
    print(inspect(button))
end

function love.update(dt)
    button:update()
end

function love.draw()
    button:draw()
end

-- function love.update(dt)
--     game:update(dt)
-- end

-- function love.draw()
--     game:draw()
-- end

-- function love.keypressed(key, scancode, isrepeat)
--     game:keyPressed(key, scancode, isrepeat)
-- end

-- function love.keyreleased(key, scancode)
--     game:keyReleased(key, scancode)
-- end

-- function love.mousepressed(x, y, button, istouch)
--     game:mousePressed(x, y, button, istouch)
-- end

-- function love.mousereleased(x, y, button, istouch)
--     game:mouseReleased(x, y, button, istouch)
-- end

-- function love.mousemoved(x, y, dx, dy, istouch)
--     game:mouseMoved(x, y, dx, dy, istouch)
-- end

-- function love.textinput(text)
--     game:textInput(text)
-- end

-- function love.wheelmoved(x, y)
--     game:wheelMoved(x, y)
-- end
