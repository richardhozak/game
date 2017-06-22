local Game = require("game")
local Ui = require("ui")
local nui = require("newui")
local game
local menu
local testmenu

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

    menu = testmenu()
    --print("asd")
end

function love.update(dt)
    --menu:update(dt)

end

function love.draw()
    --menu:draw()
    love.graphics.setColor(255,255,255,100)
    love.graphics.rectangle("fill", 0, 0, menu.width, menu.height)
    nui.draw(menu)
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
