local requiredir = (...):match("(.-)[^%.]+$")
local function requireitem(item) return require(requiredir .. item) end

local utf8 = require("utf8")
local util = requireitem("util")
local Item = requireitem("item")
local Input = Item:extend("input")

function Input:new()
	self.super.new(self)
	self.width = self.width or 100
	self.height = self.height or 25
	self.text = self.text or ""
	self.radius = self.radius or 0
	self.active = false
	self.position = 1
	self.font = love.graphics.getFont()
	self.caretX = 0
	self.caretHeight = 0
	self.mouseover = false
	self.cursor = love.mouse.getSystemCursor("ibeam")
	self.bindings = self:createBindings()
end

function Input:mousePressed(x, y, button, istouch)
	if self.super.mousePressed(self, x, y, button, istouch) then
		return true
	end

	Item.hotitem = self
    return true
end

function Input:update()
	if self.mouseover then
		love.mouse.setCursor(self.cursor)
	else
		love.mouse.setCursor()
	end
	self:evaluateBindings(self.bindings)
	self.super.update(self)
end

function Input:textInput(text)
	if Item.hotitem ~= self then
		return self.super.textInput(self, text)
	end

	self.text = util.text.insertAt(self.text, text, self.position-1)
	self:setPosition(self.position + utf8.len(text))
	return true
end

function Input:getMaxPosition()
	return utf8.len(self.text) + 1
end

function Input:setPosition(newPosition)
	local maxPosition = utf8.len(self.text) + 1
	if newPosition < 1 then
		newPosition = 1
	elseif newPosition > maxPosition then
		newPosition = maxPosition
	end

	if self.position ~= newPosition then
		self.position = newPosition
		self:updateCaret()
	end
end

function Input:updateCaret()
	local caretOffsetX = self.font:getWidth(string.sub(self.text, 1, utf8.offset(self.text, self.position) - 1))
	self.caretX = self.x + caretOffsetX
	self.caretHeight = self.font:getHeight()
end

function Input:keyPressed(key, scancode, isrepeat)
	if Item.hotitem ~= self then
		return self.super.keyPressed(self, key, scancode, isrepeat)
	end

	if key == "backspace" then
		local removeAtPosition = self.position - 1
  		if removeAtPosition < 1 then
  			return
  		end
		self.text = util.text.removeAt(self.text, removeAtPosition)
		self:setPosition(removeAtPosition)
    elseif key == "delete" then
    	if self.position == self:getMaxPosition() then
    		return
    	end
    	self.text = util.text.removeAt(self.text, self.position)
   	elseif key == "left" then
   		self:setPosition(self.position - 1)
   	elseif key == "right" then
   		self:setPosition(self.position + 1)
	elseif key == "home" then
		self:setPosition(1)
	elseif key == "end" then
		self:setPosition(self:getMaxPosition())
	elseif key == "return" then
		util.emit(self.onAccepted, self.text)
    end
end

function Input:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill",self.x, self.y, self.width, self.height, self.radius)

	love.graphics.setScissor(self.x, self.y, self.width, self.height)
	love.graphics.setColor(50,50,50)
	local yOffset = math.floor((self.height - self.font:getHeight()) / 2)
	love.graphics.print(self.text, self.x, self.y + yOffset)
	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle("rough")
	love.graphics.line(self.caretX, self.y + yOffset, self.caretX, self.y + self.caretHeight + yOffset)
	love.graphics.setScissor()
	
	love.graphics.setColor(100,100,100)
	love.graphics.setLineWidth(2)
	love.graphics.setLineStyle("smooth")
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height, self.radius)
end

return Input