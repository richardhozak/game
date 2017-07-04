inspect = require("lib.inspect")

local Game = require("game")
local ui = require("ui")
local game

local count = 2

local displayText = ""

function love.load()
    io.stdout:setvbuf("no")
    love.graphics.setFont(love.graphics.newFont("fonts/OpenSans-Light.ttf", 18))

    love.window.setMode(800, 600, {x=1119, y=25, resizable=true})
    -- love.window.setMode(800, 600, {x=2100, y=800, resizable=true})
    game = Game()

    -- view = ui.column {
    --     id="rootcolumn",
    --     x=0,y=0,spacing=20,
    --     ui.repeater {
    --         id="toprepeater",
    --         times=function(self) return count end,
    --         ui.button {
    --             id="toprepeaterbutton",
    --             radius=20,
    --             onPressed=function(self) return function() count = count + 1 end end
    --         },
    --     },
    --     ui.button {
    --         id="increment",
    --         onPressed=function(self) return function() count = count + 1 end end
    --     },
    --     ui.button {
    --         id="decrement",
    --         onPressed=function(self) return function() count = count - 1 end end
    --     },
    --     ui.repeater {
    --         id="bottomrepeater",
    --         times=function(self) return count end,
    --         ui.row {
    --             id="bottomrepeaterrow",
    --             ui.repeater {
    --                 id="rowbutton",
    --                 times=3,
    --                 ui.button {
    --                     radius=20,
    --                     onPressed=function(self) return function() self.parent.times = self.parent.times + 1 end end
    --                 },
    --             }
    --         }
    --     },
    -- }
end

-- function love.update(dt)
--     view:update()
--     --print(inspect(view))
-- end

-- function love.draw()
--     view:draw()
-- end

-- function love.mousepressed(x, y, button, istouch)
--     local pressed = view:mousePressed(x, y, button, istouch)
--     print("mousepressed", x, y, button, pressed)

-- end

-- function love.mousereleased(x, y, button, istouch)
--     local released = view:mouseReleased(x, y, button, istouch)
--     print("mousereleased", x, y, button, released)
-- end

-- function love.mousemoved(x, y, dx, dy, istouch)
--     local moved = view:mouseMoved(x, y, dx, dy, istouch)
--     -- print("mousemoved", x, y, dx, dy, moved)
-- end

-- function love.keypressed(key)
--    if key == "tab" then
--       local state = not love.mouse.isGrabbed()   -- the opposite of whatever it currently is
--       love.mouse.setGrabbed(state)
--    end
-- end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
    love.graphics.print(displayText)
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
    displayText = displayText .. text
    game:textInput(text)
end

function love.wheelmoved(x, y)
    game:wheelMoved(x, y)
end
