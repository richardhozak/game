local Object = require("lib.classic")
local Ui = Object:extend()

local util = require("util")

function Ui:new()
    self.isPaused = false
end

function Ui:update(dt)
    if love.mouse.isVisible() and not self.isPaused then
        love.mouse.setVisible(false)
    end
end

function Ui:drawPauseMenu()

end

function Ui:drawCursor()
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

function Ui:draw(x, y, width, height)
    if self.isPaused then
        --util.drawFilledRectangle(x, y, width, height, 236, 240, 241)
        util.drawFilledRectangle(x, y, width, height, 44, 62, 80)
    else

    end
end

return Ui()