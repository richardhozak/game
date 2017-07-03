inspect = require("lib.inspect")

local Game = require("game")
local oui = require("ui")
local ui = require("newui")
local game

function love.load()
    io.stdout:setvbuf("no")
    

    -- love.window.setMode(800, 600, {x=1119, y=25, resizable=true})
    love.window.setMode(800, 600, {x=2100, y=800, resizable=true})
    print("game started")
    game = Game()
    view = ui.view {
        id="view1",
        ui.row {
            id="column1",
            x=0,y=0,spacing=20,
            ui.button {
                id="button1",
                onPressed=function(self) return function() print("first pressed") end end,
                onReleased=function(self) return function() print("first released") end end,
                onClicked=function(self) return function() print("first clicked") end end,
                onCanceled=function(self) return function() print("first canceled") end end,
                color=function(self) 
                    return self.pressed and {255,255,255,100} or self.mouseover and {20,20,20} or {255,255,255}
                end
            },
            ui.button {
                id="button2",
                onPressed=function(self) return function() print("first pressed") end end,
                onReleased=function(self) return function() print("first released") end end,
                onClicked=function(self) return function() print("first clicked") end end,
                onCanceled=function(self) return function() print("first canceled") end end,
                color=function(self) 
                    return self.pressed and {255,255,255,100} or self.mouseover and {20,20,20} or {255,255,255}
                end
            }
        }
    }
    print(inspect(view))
end

function love.update(dt)
    view:update()
    --print(inspect(view))
end

function love.draw()
    view:draw()
end

function love.mousepressed(x, y, button, istouch)
    local pressed = view:mousePressed(x, y, button, istouch)
    print("mousepressed", x, y, button, pressed)

end

function love.mousereleased(x, y, button, istouch)
    local released = view:mouseReleased(x, y, button, istouch)
    print("mousereleased", x, y, button, released)
end

function love.mousemoved(x, y, dx, dy, istouch)
    local moved = view:mouseMoved(x, y, dx, dy, istouch)
    -- print("mousemoved", x, y, dx, dy, moved)
end

function love.keypressed(key)
   if key == "tab" then
      local state = not love.mouse.isGrabbed()   -- the opposite of whatever it currently is
      love.mouse.setGrabbed(state)
   end
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
