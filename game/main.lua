inspect = require("lib.inspect")

local Game = require("game")
local nui = require("newnewui")
local files = {
    "one",
    "two",
    "three",
    "four"
}

function love.load()
    love.window.setMode(800, 600, {x=1119, y=25, resizable=true})

    column = nui.column {
        spacing = 5,
        nui.button {
            width=100,
            height=50,
            color={255,255,255},
            onClicked=function(t)
                return function() 
                    table.insert(files, "another one " .. #files)
                    print("clicked1", #files) 
                end
            end
        },
        nui.repeater {
            times=function() return #files end,
            nui.button {
                width=100,
                height=50,
                color=function(t)
                    return t.mouseover and {20,20,20} or {255,255,255,100}
                end,
                text={
                    value=function(t)
                        return files[t.index]
                    end,
                    color=function(t)
                        return t.mouseover and {255,255,255} or {20,20,20}
                    end,
                },
                onClicked=function(t)
                    return function() print("clicked" .. t.text.value) end
                end
            }
        },
    }
    
    --button.update()

    --print(column.x)
end

function love.update(dt)
    column()
end

function love.draw()
    --nui.draw(button)
    --button:draw()
    nui.drawItem(column)
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
