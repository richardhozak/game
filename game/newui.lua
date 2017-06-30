local Item = require("item")

local function pointInRect(px, py, rx, ry, rw, rh)
	return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

local function callIfFunction(func)
	if type(func) == "function" then
		func()
	end
end

local function updateChildren(t, root)
	root = root or t
	for index, child in ipairs(t) do
		child.parent = root
		pcall(child)
		if not child.name then
			child.parent = nil
			updateChildren(child, root)
		end
	end
end

-- creates bindings table from functions that are present in 'context' table (recursively)
local function createBindings(context)
	local bindings = nil
	for key, value in pairs(context) do
		if type(value) == "function" then
			if not bindings then bindings = {} end
			bindings[key] = value
		elseif type(value) == "table" and value ~= bindings and type(key) ~= "number" then
			local subbindings = createBindings(value)
			if subbindings then
				if not bindings then bindings = {} end
				bindings[key] = subbindings
			end
		end
	end

	return bindings
end

local function evaluateBindings(bindings, context, arg)
	if not bindings then return end
	if not arg then
		arg = context
	end

	for key, value in pairs(bindings) do
		if type(value) == "function" then
			context[key] = value(arg)
		elseif type(value) == "table" then
			--print("evaluating", key, value, inspect(value), inspect(context[key]))
			evaluateBindings(value, context[key], arg)
		end
	end
end

local Button = Item:extend("button")
function Button:new()
	self.x = self.x or 0
	self.y = self.y or 0
	self.radius = self.radius or 0
	self.width = self.width or 0
	self.height = self.height or 0
	self.color = self.color or {255,255,255}

	if self.border then
		self.border.width = self.border.width or 0
		self.border.color = self.border.color or {0,0,0,0}
	end

	self.pressed = false
	self.mouseover = false
	self.down = false

	if not self.bindings then
		self.bindings = createBindings(self)
	end

	self.pressedRegistered = false

	print("bindings", inspect(self.bindings))
end

function Button:update()
	local mx, my = love.mouse.getPosition()
	self.mouseover = pointInRect(mx, my, self.x, self.y, self.width, self.height)

	evaluateBindings(self.bindings, self)

	if love.mouse.isDown(1) then
		if self.mouseover then
			if not self.down then
				self.down = true
				callIfFunction(self.onPressed)
			end
			self.pressed = true
		else
			self.pressed = false
		end
	else
		if self.down then
			if currentItem == t then
				currentItem = nil
			end

			self.pressed = false
			self.down = false
			if self.mouseover then
				callIfFunction(self.onReleased)
				callIfFunction(self.onClicked)
			else
				callIfFunction(self.onCanceled)
			end
		end
	end
end

function Button:draw()
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.radius)
	
	if self.border then
		love.graphics.setColor(self.border.color)
		love.graphics.setLineWidth(self.border.width)
		love.graphics.rectangle("line", self.x, self.y, self.width, self.height, self.radius)
	end

	if self.text then
		local font = love.graphics.getFont()
		local xOffset = (self.width - font:getWidth(self.text.value)) / 2
		local yOffset = (self.height - font:getHeight()) / 2
		love.graphics.setColor(self.text.color)
		love.graphics.print(self.text.value, math.floor(self.x + xOffset), math.floor(self.y + yOffset))
	end
end

function Button:layout()
end

local function components()
	local variables = {}
	local id = 1
	while true do 
		local index, value = debug.getlocal(2, id)
		if index then
			if type(value) == "table" and value.name then
				variables[value.name] = value
			end
		else
			break
		end
		id = id + 1
	end
	return variables
end

local allcomponents = components()

return allcomponents