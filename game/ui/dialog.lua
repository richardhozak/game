local Object = require("lib.classic")
local util = require("util")

local Dialog = Object:extend()

function Dialog:new()
    self.items = {}
    self.index = 1
    self.currentItem = nil
    self.titleFont = love.graphics.newFont("fonts/OpenSans-Regular.ttf", 30)
    self.normalFont = love.graphics.newFont("fonts/OpenSans-Regular.ttf", 20)
    self.canNext = false
end

function Dialog:update(dt)
    self.isEnd = self.index == #self.items
    self.canNext = self.index <= #self.items
    self.currentItem = self.items[self.index]
end

function Dialog:draw(x, y, width, height)
    local height = height - y
    util.drawFilledRectangle(x, y, width, height, 149, 165, 166)

    if self.currentItem then
        love.graphics.setFont(self.titleFont)
        local titlePosX = x + 10
        if self.currentItem.side == "right" then
            titlePosX = width - self.titleFont:getWidth(self.currentItem.title) - 10
        end
        love.graphics.print(self.currentItem.title, titlePosX, y)
        love.graphics.setFont(self.normalFont)
        love.graphics.printf(self.currentItem.text, x + 30, y + 40, width - 20)

        if self.isEnd then
            love.graphics.print("E - konec", x + 10, y + height - self.normalFont:getHeight() - 10)
        else
            love.graphics.print("E - pokračovat", x + 10, y + height - self.normalFont:getHeight() - 10)
        end
    end
end

function Dialog:add(side, title, text)
    table.insert(self.items, {side=side, title=title, text=text})
end

function Dialog:next()
    if self.canNext then
        self.index = self.index + 1
    end
end

return Dialog