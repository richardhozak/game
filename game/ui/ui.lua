local bump = require("lib.bump")

local Button = require("ui.button")

local Object = require("lib.classic")
local Ui = Object:extend()

local util = require("util")

function Ui:new()
    self.items = bump.newWorld()
    self.isPaused = false
    Button(self, self.items, 0,0,100,100, {
        color={246,36,89}, 
        text="TEST",
        onPressed=function() 
            print("pressed") 
        end
        })
end

function Ui:update(dt)
    local elements, len = self.items:getItems()
    for i=1, len do
        elements[i]:update(dt)
    end

    --[[
    if love.mouse.isVisible() and not self.isPaused then
        love.mouse.setVisible(false)
    end
    --]]
end

function Ui:getMousePosition()
    return love.mouse.getPosition()
end

function Ui:isMouseDown()
    return love.mouse.isDown(1)
end

function Ui:draw(x, y, width, height)
    local elements, len = self.items:getItems()
    for i=1, len do
        elements[i]:draw()
    end

    if self.isPaused then
        --util.drawFilledRectangle(x, y, width, height, 236, 240, 241)
        --util.drawFilledRectangle(x, y, width, height, 44, 62, 80)
        --self:drawPauseMenu()
    else

    end
end

function Ui.onPaused()
    if self.paused then
    else
    end
end

function Ui:getPaused()
    return self.paused
end

function Ui:setPaused(paused)
    if self.paused ~= paused then
        self.paused = paused
        self.onPaused()
    end
end

return Ui()