local ui = {}
local layout = {}
local update = {}

local function pointInRect(px, py, rx, ry, rw, rh)
	return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
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

function update.button(t)
	local mx, my = love.mouse.getPosition()
	t.mouseover = pointInRect(mx, my, t.x, t.y, t.width, t.height)

	evaluateBindings(t.bindings, t)

	if t.mouseover and love.mouse.isDown(1) then
		t.pressed = true
		if not t.pressedRegistered then
			t.pressedRegistered = true
			callIfFunction(t.onPressed)
		end
	elseif t.pressed then
		t.pressed = false
		t.pressedRegistered = false
		callIfFunction(t.onClicked)
		callIfFunction(t.onReleased)
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

	if not t.bindings then
		t.bindings = createBindings(t)
	end

	t.pressedRegistered = false

	return setmetatable(t, {
		__call = update.button
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

local function clearArray(t)
	for index, value in ipairs(t) do
		t[index] = nil
	end
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

function ui.drawItem(item)
	if type(item) == "table" then
		if item.name == "button" then
			love.graphics.setColor(item.color)
			love.graphics.rectangle("fill", item.x, item.y, item.width, item.height, item.radius)
			
			if item.border then
				love.graphics.setColor(item.border.color)
				love.graphics.setLineWidth(item.border.width)
				love.graphics.rectangle("line", item.x, item.y, item.width, item.height, item.radius)
			end

			if item.text then
				local font = love.graphics.getFont()
				local xOffset = (item.width - font:getWidth(item.text.value)) / 2
				local yOffset = (item.height - font:getHeight()) / 2
				love.graphics.setColor(item.text.color)
				love.graphics.print(item.text.value, math.floor(item.x + xOffset), math.floor(item.y + yOffset))
			end
		else
			for index, child in ipairs(item) do
				ui.drawItem(child)
			end

			if item.name == "repeater" then
				love.graphics.setColor(100,255,100, 100)
			elseif item.name == "row" then
				love.graphics.setColor(255,100,100,150)
			else
				love.graphics.setColor(255,255,255,0)
			end

			love.graphics.rectangle("line", item.x, item.y, item.width, item.height)
		end
	end
end

function ui.draw(t)
	for index, item in ipairs(t) do
		--print(index, type(item) == "table" and item.name or item, type(item))
		if type(item) == "table" then
			if item.name == "button" or item.name == "newbutton" then
				love.graphics.setColor(item.color)
				love.graphics.rectangle("fill", item.x, item.y, item.width, item.height, item.radius)
				if item.border then
					love.graphics.setColor(item.border.color)
					love.graphics.setLineWidth(item.border.width)
					love.graphics.rectangle("line", item.x, item.y, item.width, item.height, item.radius)
					if item.text then
						local font = love.graphics.getFont()
						local xOffset = (item.width - font:getWidth(item.text)) / 2
						local yOffset = (item.height - font:getHeight()) / 2
						love.graphics.print(item.text, item.x + xOffset, item.y + yOffset)
					end
				end
			else
				--love.graphics.push()
				--love.graphics.translate(item.x, item.y)
				ui.draw(item.children)
				--love.graphics.pop()
			end
		end
	end
end

return ui