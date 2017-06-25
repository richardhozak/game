local Game = require("game")
local Ui = require("ui")
local nui = require("newui")
local game
local menu, col
local testmenu, testcol

function love.load()
    love.window.setMode(800, 600, {x=1119, y=25, resizable=true})
    --game = Game()

    --[[
    menu = Ui {
        Ui:row {
            x = 0,
            y = 0,
            spacing = 10,

            Ui:button {
                width = 100,
                height = 50,
                color = {102, 51, 153},
            },
        },
        Ui:column {
            x=110,
            Ui:button {
                width = 100,
                height = 50,
                color = {68, 108, 179},
            },
            Ui:button {
                width = 100,
                height = 50,
                color = {46, 62, 80},
            }
        }
    }
    menu = Ui {
        Ui:rowFunc {
            x = 0,
            y = 0,
            spacing = 0,

            Ui:button {
                width = 100,
                height = 50,
                color = {68, 108, 179},
            },
            Ui:button {
                width = 100,
                height = 50,
                color = {46, 62, 80},
            }
        }
    }
    --]]

    --[[
    testmenu = nui.row {
        spacing = 10,
        nui.button {
            width = 100,
            height = 50,
            color = {102, 51, 153},
        },
        nui.button {
            width = 100,
            height = 50,
            color = {68, 108, 179},
        },
        nui.column {
            spacing = 10,
            nui.button {
                width = 100,
                height = 50,
                color = {46, 62, 80},
            },
            nui.button {
                width = 100,
                height = 50,
                color = {46, 62, 80},
            },
        },
        nui.column {
            spacing = 10,
            nui.button {
                width = 100,
                height = 50,
                color = {46, 62, 80},
            },
            nui.button {
                width = 100,
                height = 50,
                color = {46, 62, 80},
            },
            nui.row {
                spacing = 10,
                nui.button {
                    width = 100,
                    height = 50,
                    color = {102, 51, 153},
                },
                nui.button {
                    width = 100,
                    height = 50,
                    color = {68, 108, 179},
                },
                nui.column {
                    spacing = 10,
                    nui.button {
                        width = 100,
                        height = 50,
                        color = {102, 51, 153},
                    },
                    nui.button {
                        width = 100,
                        height = 50,
                        color = {68, 108, 179},
                    },
                }
            }
        }
    }
    --]]

    testmenu = nui.column {
        spacing = 10,
        nui.button {
            width = 100,
            height = 50,
            radius = 5,
            border = {
                width = 2,
                color = {255,255,255},
            },
            text = love.timer.getFPS,
            color = function(b)
                if b.pressed then
                    return {46, 62, 80}
                elseif b.mouseOver then
                    return {102, 51, 153}
                else
                    return {55,55,55}
                end
            end,
            onPressed = function(b)
                return function()
                    print("onPressed called")
                end
            end,
            onReleased = function(b)
                return function()
                    print("onReleased called")
                end
            end,
            onClicked = function(b)
                return function()
                    print("onClicked called")
                end
            end,
            --color = {46, 62, 80},
        },
        nui.button {
            width = 100,
            height = 50,
            color = {102, 51, 153},
        },
        nui.row {
            spacing = 10,
            nui.button {
                width = 100,
                height = 50,
                color = {102, 51, 153},
            },
            nui.button {
                width = 100,
                height = 50,
                color = {68, 108, 179},
            },
            nui.column {
                spacing = 10,
                --[[nui.repeater {
                    times = 3,
                    updater = nui.column,
                    nui.button {
                        width = 100,
                        height = 25,
                        color = {255,255,255},
                    }
                },--]]
                nui.button {
                    width = 100,
                    height = 50,
                    color = {102, 51, 153},
                },
                nui.button {
                    width = 100,
                    height = 50,
                    color = {68, 108, 179},
                },
            }
        }
    }

    --[[testcol = nui.repeater {
        x = 400,
        y = 200,
        times = 3,
        spacing = 10,
        updater = nui.column,
        delegate = nui.newbutton {
            width = 100,
            height = 25,
            color = function(b) 
                return b.pressed and {20,20,20,255} or {255,255,255} 
            end,
            onClicked = function(b)
                return function()
                    print("clicked", b.index)
                end
            end
        }
    }]]--

    testcol = nui.column {
        x = 400,
        y = 200,
        spacing = 10,
        nui.repeater {
            times = 3,
            --updater = nui.column,
            delegate = nui.button {
                width = 100,
                height = 25,
                color = function(b) 
                    return b.pressed and {20,20,20,255} or {255,255,255} 
                end,
                onClicked = function(b)
                    return function()
                        print("clicked", b.index)
                    end
                end
            }
        },
        nui.button {
            width = 100,
            height = 50,
            color = function(b) 
                return b.pressed and {20,20,20,255} or {102, 51, 153}
            end,
            onClicked = function() 
                return function() 
                    print("first clicked") 
                end
            end
        },
        nui.button {
            width = 100,
            height = 50,
            color = function(b) 
                return b.pressed and {20,20,20,255} or {68, 108, 179}
            end,
            onClicked = function() 
                return function() 
                    print("second clicked") 
                end
            end
        },
    }

    --menu = testmenu()
    --menu = testmenu(20,20)
    --print("asd")
end

local menuX = 0

function love.update(dt)
    --menu:update(dt)
    --menuX = menuX + dt*50
    menu = testmenu()
    col = testcol()
end

function love.draw()
    --menu:draw()
    love.graphics.setColor(255,255,255,100)
    love.graphics.rectangle("fill", 0, 0, menu.width, menu.height)
    nui.draw(menu.children)
    nui.draw(col.children)

    love.graphics.setColor(255,255,255)
    love.graphics.rectangle("line", col.x, col.y, 300, 300)

    love.graphics.print(love.timer.getFPS())
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
