local ui = {}
local layout = {}
local update = {}
local draw = {}
local Object = require("lib.classic")

local function pointInRect(px, py, rx, ry, rw, rh)
	return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

local function clearArray(t)
	for index, value in ipairs(t) do
		t[index] = nil
	end
end

local Mouse = Object:extend()

function Mouse:new()
	self.hierarchy = {}
	self.active = nil
end

function Mouse:add(item)
	self.hierarchy[#self.hierarchy+1] = item
	return #self.hierarchy
end

function Mouse:pressed(x, y, button)
	if button ~= 1 then
		return false
	end

	self.active = nil
	
	for i=#self.hierarchy, 1,-1 do
		local item = self.hierarchy[i]
		if pointInRect(x, y, item.x, item.y, item.width, item.height) then
			self.active = item
			return true
		end
	end

	return false
end

function Mouse:released(x, y, button)
	if button ~= 1 then
		return false
	end

	if self.active then
		self.active = nil
		return true
	end

	return false
end

function Mouse:hasMouse(item)
	return self.active == item
end

ui.mouse = Mouse()

local currentItem = nil

function ui.lightness(color)
  --return (0.299*color[1] + 0.587*color[2] + 0.114*color[3]) / 255
  local r, g, b = color[1], color[2], color[3]
  return ((r+r+b+g+g+g)/6)/255
end

function ui.brightness(color)
	local r, g, b = color[1], color[2], color[3]
	return math.sqrt(r*r*0.241 + g*g*0.691 + b*b*0.068)
end

-- deep-copy a table
local function clone(t)
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = clone(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
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

function ui.button(t)
	t.name = "button"
	t.x = t.x or 0
	t.y = t.y or 0
	t.radius = t.radius or 0
	t.width = t.width or 0
	t.height = t.height or 0
	t.color = t.color or {255,255,255}

	if t.border then
		t.border.width = t.border.width or 0
		t.border.color = t.border.color or {0,0,0,0}
	end

	t.pressed = false
	t.mouseover = false
	t.down = false

	if not t.bindings then
		t.bindings = createBindings(t)
	end

	t.pressedRegistered = false

	return setmetatable(t, {
		__call = update.button
	})
end

function ui.column(t)
	t.name = "column"
	t.x = t.x or 0
	t.y = t.y or 0
	t.width = t.width or 0
	t.height = t.height or 0
	t.spacing = t.spacing or 0

	if not t.bindings then
		t.bindings = createBindings(t)
	end

	return setmetatable(t, {
		__call = update.column
	})
end

function ui.row(t)
	t.name = "row"
	t.x = t.x or 0
	t.y = t.y or 0
	t.width = t.width or 0
	t.height = t.height or 0
	t.spacing = t.spacing or 0

	if not t.bindings then
		t.bindings = createBindings(t)
	end

	return setmetatable(t, {
		__call = update.row
	})
end

function ui.repeater(t)
	t.name = "repeater"
	t.x = t.x or 0
	t.y = t.y or 0
	t.width = t.width or 0
	t.height = t.height or 0
	t.times = t.times or 1

	if not t.bindings then
		t.bindings = createBindings(t)
	end

	t.lastTimes = 0
	t.delegate = t.delegate or clone(t[1])
	t[1] = nil

	return setmetatable(t, {
		__call = update.repeater
	})
end

function layout.row(t, spacing, root)
	root = root or t
	local width, height = 0, 0
	
	for index, child in ipairs(t) do
		local childWidth, childHeight = 0, 0

		if child.name then
			child.x = root.x + width
			child.y = root.y
			childWidth, childHeight = child.width, child.height
		else
			childWidth, childHeight = layout.row(child, spacing, root)
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

function layout.column(t, spacing, root)
	root = root or t
	local width, height = 0, 0

	for index, child in ipairs(t) do
		local childWidth, childHeight = 0, 0

		if child.name then
			child.x = root.x
			child.y = root.y + height
			childWidth, childHeight = child.width, child.height
		else
			childWidth, childHeight = layout.column(child, spacing, root)
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

function update.button(t)
	-- local mx, my = love.mouse.getPosition()
	-- t.mouseover = pointInRect(mx, my, t.x, t.y, t.width, t.height)

	if not t.mouseId then
		t.mouseId = ui.mouse:add(t)
	end

	t.mouseover = ui.mouse:hasMouse(t)

	evaluateBindings(t.bindings, t)

	if love.mouse.isDown(1) then
		if currentItem and currentItem ~= t then
			return
		end

		if t.mouseover then
			currentItem = t

			if not t.down then
				t.down = true
				callIfFunction(t.onPressed)
			end
			t.pressed = true
		else
			t.pressed = false
		end
	else
		if t.down then
			if currentItem == t then
				currentItem = nil
			end

			t.pressed = false
			t.down = false
			if t.mouseover then
				callIfFunction(t.onReleased)
				callIfFunction(t.onClicked)
			else
				callIfFunction(t.onCanceled)
			end
		end
	end
end

function update.column(t)
	evaluateBindings(t.bindings, t)
	t.width, t.height = layout.column(t, t.spacing)
	updateChildren(t)
end

function update.row(t)
	evaluateBindings(t.bindings, t)
	t.width, t.height = layout.row(t, t.spacing)
	updateChildren(t)
end

function update.repeater(t)
	evaluateBindings(t.bindings, t)

	if t.times < 0 then
		t.times = 0
	end

	if t.times ~= t.lastTimes then
		if t.times > t.lastTimes then
			local appendTimes = t.times - t.lastTimes
			for i=1, appendTimes do
				local item = clone(t.delegate)
				local index = #t+1
				item.index = index
				t[index] = item
			end
		elseif t.times < t.lastTimes then
			local removeTimes = t.lastTimes - t.times
			for i=1, removeTimes do
				t[#t] = nil
			end
		end

		t.lastTimes = t.times
	end

	if t.parent then
		t.width, t.height = layout[t.parent.name](t, t.parent.spacing)
	else
		print("repeater does not have parent")
	end

	updateChildren(t)
end

function draw.button(t)
	love.graphics.setColor(t.color)
	love.graphics.rectangle("fill", t.x, t.y, t.width, t.height, t.radius)
	
	if t.border then
		love.graphics.setColor(t.border.color)
		love.graphics.setLineWidth(t.border.width)
		love.graphics.rectangle("line", t.x, t.y, t.width, t.height, t.radius)
	end

	if t.text then
		local font = love.graphics.getFont()
		local xOffset = (t.width - font:getWidth(t.text.value)) / 2
		local yOffset = (t.height - font:getHeight()) / 2
		love.graphics.setColor(t.text.color)
		love.graphics.print(t.text.value, math.floor(t.x + xOffset), math.floor(t.y + yOffset))
	end
end

function ui.draw(item)
	if type(item) == "table" then
		if item.name and draw[item.name] then
			draw[item.name](item)
		else
			for index, child in ipairs(item) do
				ui.draw(child)
			end

			--[[
			if item.name then
				if item.name == "repeater" then
					love.graphics.setColor(100,255,100, 100)
				elseif item.name == "row" then
					love.graphics.setColor(255,100,100,150)
				else
					love.graphics.setColor(255,255,255,0)
				end

				love.graphics.rectangle("line", item.x, item.y, item.width, item.height)
			end
			--]]
		end
	end
end

return ui