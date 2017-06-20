local Object = require("lib.classic")
local lume = require("lib.lume")

local Camera = Object:extend()

function Camera:new()
    self.x = 0
    self.y = 0
    self.scale = 1
    self.width = 0
    self.height = 0
    self.scaledWidth = 0
    self.scaledHeight = 0
    
    self.lockOn = nil

    self.bounds = {}
    self.bounds.enabled = false
    self.bounds.x = 0
    self.bounds.y = 0
    self.bounds.width = 0
    self.bounds.height = 0
end

function Camera:update(dt)
    self.width = love.graphics.getWidth()
    self.height = love.graphics.getHeight()
    self.scaledWidth = self.width * self.scale
    self.scaledHeight = self.height * self.scale

    if self.bounds.enabled then
        local entityX, entityY = nil, nil

        if self.lockOn and type(self.lockOn.getCenter) == "function" then
            entityX, entityY = self.lockOn:getCenter()
        end

        if self.bounds.width < self.scaledWidth then
            self.x = -((self.scaledWidth - self.bounds.width) / 2) + self.bounds.x
        else
            local x = entityX and entityX - self.scaledWidth / 2 or self.x
            self.x = lume.clamp(x, self.bounds.x, self.bounds.x + self.bounds.width - self.scaledWidth)
        end

        if self.bounds.height < self.scaledHeight then
            self.y = -((self.scaledHeight - self.bounds.height) / 2) + self.bounds.y
        else
            local y = entityY and entityY - self.scaledHeight / 2 or self.y
            self.y = lume.clamp(y, self.bounds.y, self.bounds.y + self.bounds.height - self.scaledHeight)
        end
    end
end

function Camera:draw(func)
    love.graphics.push()
    love.graphics.scale(1 / self.scale, 1 / self.scale)
    love.graphics.translate(-self.x, -self.y)

    func(self.x, self.y, self.scaledWidth, self.scaledHeight)

    love.graphics.pop()
end

function Camera:lookAt(entity)
    self.lockOn = entity
end

function Camera:setBounds(x, y, width, height)
    if x == nil then
        self.bounds.enabled = false
    else
        self.bounds.x, self.bounds.y = x, y
        self.bounds.width, self.bounds.height = width, height
        self.bounds.enabled = true
    end
end

function Camera:setPosition(x, y)
    self.x, self.y = x, y
end

function Camera:move(dx, dy)
    self.x = self.x + dx * self.scale
    self.y = self.y + dy * self.scale
end

function Camera:getMousePosition()
  return self:getMouseX(), self:getMouseY()
end

function Camera:getMouseX()
    return love.mouse.getX() * self.scale + self.x
end

function Camera:getMouseY()
    return love.mouse.getY() * self.scale + self.y
end

function Camera:setScale(scale)
    self.scale = lume.clamp(scale, 1, 4)
end

return Camera