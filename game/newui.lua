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
		if child.name then
			child.parent = root
			child:update()
		else
			if type(child.update) == "function" then
				child:update()
			else
				updateChildren(child, root)
			end
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

local View = Item:extend("view")
function View:new()
	self.x = self.x or 0
	self.y = self.y or 0
	self.width = self.width or love.graphics.getWidth()
	self.height = self.height or love.graphics.getHeight()
end

function View:update()
	for index, child in ipairs(self) do
		child:layout()
	end

	updateChildren(self)
end

function View:draw()
	for index, child in ipairs(self) do
		child:draw()
	end
end

local Button = Item:extend("button")
function Button:new()
	self.x = self.x or 0
	self.y = self.y or 0
	self.radius = self.radius or 0
	self.width = self.width or 100
	self.height = self.height or 50
	self.color = self.color or {255,255,255}

	if self.border then
		self.border.width = self.border.width or 0
		self.border.color = self.border.color or {0,0,0,0}
	end

	self.pressed = false
	self.mouseover = false
	self.down = false

	self.bindings = createBindings(self)
end

function Button:update()
	evaluateBindings(self.bindings, self)

	if self.down then
		if self.mouseover then
			if not self.pressed then
				self.pressed = true
				callIfFunction(self.onPressed)
			end
		end
	else
		if self.pressed then
			self.pressed = false
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

local Column = Item:extend("column")
function Column:new()
	self.x = self.x or 0
	self.y = self.y or 0
	self.width = self.width or 0
	self.height = self.height or 0
	self.spacing = self.spacing or 10
	self.bindings = createBindings(self)
end

function Column:update()
	evaluateBindings(self.bindings, self)
	updateChildren(self)
end

function Column:draw()
	for index, child in ipairs(self) do
		child:draw()
	end
end

function Column:layout()
	local function doLayout(t, spacing, root)
		root = root or t
		local width, height = 0, 0

		for index, child in ipairs(t) do
			local childWidth, childHeight = 0, 0

			if child.name then
				child.x = root.x
				child.y = root.y + height
				childWidth, childHeight = child.width, child.height
			else
				childWidth, childHeight = doLayout(child, spacing, root)
			end

			local islast = index == #t
			local childSpacing = spacing

			if islast then
				if childWidth == 0 then
					childSpacing = -spacing
				else
					childSpacing = 0
				end
			elseif childWidth == 0 then
				childSpacing = 0
			end

			height = height + childHeight + childSpacing
			if childWidth > width then
				width = childWidth
			end
		end

		return width, height
	end

	self.width, self.height = doLayout(self, self.spacing)
end

local Row = Item:extend("row")
function Row:new()
	self.x = self.x or 0
	self.y = self.y or 0
	self.width = self.width or 0
	self.height = self.height or 0
	self.spacing = self.spacing or 10
	self.bindings = createBindings(self)
end

function Row:update()
	evaluateBindings(self.bindings, self)
	updateChildren(self)
end

function Row:layout()
	local function doLayout(t, spacing, root)
		root = root or t
		local width, height = 0, 0
		
		for index, child in ipairs(t) do
			local childWidth, childHeight = 0, 0

			if child.name then
				child.x = root.x + width
				child.y = root.y
				childWidth, childHeight = child.width, child.height
			else
				childWidth, childHeight = doLayout(child, spacing, root)
			end
			
			local islast = index == #t
			local childSpacing = spacing

			if islast then
				if childWidth == 0 then
					childSpacing = -spacing
				else
					childSpacing = 0
				end
			elseif childWidth == 0 then
				childSpacing = 0
			end

			width = width + childWidth + childSpacing
			if childHeight > height then
				height = childHeight
			end
		end

		return width, height
	end

	self.width, self.height = doLayout(self, self.spacing)
end

local Repeater = Item:extend("repeater")
function Repeater:new()
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