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
        spacing = 10,
        nui.button {
            width=100,
            height=50,
            color={255,255,255},
            text={
                color= {0,0,0},
                value=function(t) return "Add (" .. #files .. ")" end
            },
            onClicked=function(t) 
                return function() 
                        table.insert(files, "another"..#files) 
                    end 
                end
        },
        nui.repeater {
            times=function() return #files end,
            nui.button {
                width=100,
                height=50,
                color=function(t) 
                    return t.pressed and {255,255,255,100} or t.mouseover and {20,20,20} or {255,255,255}
                end,
                text={
                    value=function(t) return t.index .. ": " .. files[t.index] end,
                    color=function(t) return t.mouseover and {255,255,255} or {20,20,20} end,
                },
            },
        },
        nui.button {
            width=100,
            height=50,
            color={255,255,255},
            text={
                color= {0,0,0},
                value="Remove"
            },
            onClicked=function(t) 
                return function() 
                        print("remove clicked")
                        table.remove(files, #files) 
                    end 
                end
        },
    }
    
    --button.update()

    --print(column.x)
    print(inspect(column))
end

function love.update(dt)
    column()
    print(inspect(column))
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
