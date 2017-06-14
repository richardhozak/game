local Object = require("lib.classic")
local lume = require("lib.lume")

local Camera = Object:extend()

function Camera:new()
    self.posX = 0
    self.posY = 0
    self.x = 0
    self.y = 0
    self.scaleX = 1
    self.scaleY = 1
    self.width = 0
    self.height = 0

    self.region = {}
    self.region.x = self.x
    self.region.y = self.y
    self.region.width = 20 * 50
    self.region.height = 20 * 50
    self.realMaxX = 0
    self.realMaxY = 0
    self.realMinX = 0
    self.realMinY = 0
end

function Camera:update(dt)
    self.width = love.graphics.getWidth() * self.scaleX
    self.height = love.graphics.getHeight() * self.scaleY

    self.realMaxX = self.region.width - self.width
    self.realMaxY = self.region.height - self.height


    self.x = self.posX --lume.clamp(self.posX, 0, self.realMaxX)
    self.y = self.posY --lume.clamp(self.posY, 0, self.realMaxY)

    --[[
    self.x = lume.clamp(self.posX - self.width / 2, self.realMinX, self.realMaxX)
    self.y = lume.clamp(self.posY - self.height / 2, self.realMinY, self.realMaxY)
    self.realMaxX = self.region.x + self.region.width - self.width
    self.realMinX = self.region.x
    self.realMaxY = self.region.y + self.region.height - self.height
    self.realMinY = self.region.y
    --]]
end

function Camera:draw(func)
    love.graphics.push()
    love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
    love.graphics.translate(-self.x, -self.y)

    func(self.x, self.y, self.width, self.height)

    love.graphics.pop()
end

function Camera:setRegion(x, y, width, height)
    self.region.x = x
    self.region.y = y
    self.region.width = width
    self.region.height = height
end

function Camera:setPosition(x, y)
    self.posX = x
    self.posY = y
end

function Camera:getMousePosition()
  return self:getMouseX(), self:getMouseY()
end

function Camera:getMouseX()
    return love.mouse.getX() * self.scaleX + self.x
end

function Camera:getMouseY()
    return love.mouse.getY() * self.scaleY + self.y
end

function Camera:setScale(scaleX, scaleY)
    self.scaleX = lume.clamp(scaleX, 1, 4)
    self.scaleY = lume.clamp(scaleY, 1, 4)
end

return Camera()