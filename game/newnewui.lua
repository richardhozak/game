local ui = {}

local function pointInRect(px, py, rx, ry, rw, rh)
	return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

local function copy1(obj)
  if type(obj) ~= 'table' then 
  	return obj 
  end
  local res = {}
  for k, v in pairs(obj) do 
  	res[copy1(k)] = copy1(v) 
  end
  return res
end

local function copy3(obj, seen)
  -- Handle non-tables and previously-seen tables.
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end

  -- New table; mark it as seen an copy recursively.
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy3(k, s)] = copy3(v, s) end
  return res
end

local function callIfFunction(func)
	if type(func) == "function" then
		func()
	end
end

-- creates bindings in 'root' table from functions that are present in 'context' table (recursively)
local function createBindingsOld(bindings, context)
	for key, value in pairs(context) do
		if type(value) == "function" then
			bindings[key] = value
		elseif type(value) == "table" and value ~= bindings and type(key) ~= "number" then
			local subbindings = {}
			bindings[key] = subbindings
			createBindingsOld(subbindings, value)
		end
	end
end

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

function ui.button(t, defaults)
	t.name = "button"
	t.x = t.x or 0
	t.y = t.y or 0
	t.radius = t.radius or 0
	t.width = t.width or 0
	t.height = t.height or 0

	if t.border then
		t.border.width = t.border.width or 0
		t.border.color = t.border.color or {0,0,0,0}
	end

	t.pressed = false
	t.mouseover = false

	if not t.bindings then
		t.bindings = createBindings(t)
	end

	local pressedRegistered = false

	return setmetatable(t, {
		__call = function()
			local mx, my = love.mouse.getPosition()
			t.mouseover = pointInRect(mx, my, t.x, t.y, t.width, t.height)
			
			evaluateBindings(t.bindings, t)

			if t.mouseover and love.mouse.isDown(1) then
				t.pressed = true
				if not pressedRegistered then
					pressedRegistered = true
					callIfFunction(t.onPressed)
				end
			elseif t.pressed then
				t.pressed = false
				pressedRegistered = false
				callIfFunction(t.onClicked)
				callIfFunction(t.onReleased)
			end
		end
	})
end

local function applyRowLayout(t, spacing, root)
	root = root or t
	local width, height = 0, 0
	
	for index, child in ipairs(t) do
		child.x = t.x + width
		child.y = t.y
		child.parent = child.name and root or nil

		pcall(child)

		if child.name then
			width = width + child.width + (index == #t and 0 or spacing)

			if child.height > height then
				height = child.height
			end
		else
			local lw, lh = applyRowLayout(child, spacing, root)
			width = width + lw + ((index == #t or lw == 0) and 0 or spacing)

			if lh > height then
				height = lh
			end
		end
	end

	return width, height
end

local function applyColumnLayout(t, spacing, root)
	root = root or t
	local width, height = 0, 0

	for index, child in ipairs(t) do
		child.x = t.x
		child.y = t.y + height
		child.parent = child.name and root or nil

		pcall(child)
		
		if child.name then
			height = height + child.height + (index == #t and 0 or spacing)
			
			if child.width > width then
				width = child.width
			end
		else
			local lw, lh = applyColumnLayout(child, spacing, root)
			height = height + lh + ((index == #t or lh == 0) and 0 or spacing)
			
			if lw > width then
				width = width
			end
		end
	end

	return width, height
end

local function applyColumnLayoutNew(t, spacing, root)
	root = root or t
	local width, height = 0, 0

	for index, child in ipairs(t) do
		local childWidth, childHeight = 0, 0
		print("index", index)
		
		if child.name then
			child.x = root.x
			child.y = root.y + height
			childWidth, childHeight = child.width, child.height
		else
			childWidth, childHeight = applyColumnLayoutNew(child, spacing, root)
		end

		height = height + childHeight + (index == #t and 0 or spacing)
		if childWidth > width then
			width = childWidth
		end
	end

	return width, height
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

function ui.column(t, defaults)
	t.name = "column"
	t.x = t.x or 0
	t.y = t.y or 0
	t.width = t.width or 0
	t.height = t.height or 0
	t.spacing = t.spacing or defaults and defaults.spacing or 0

	if not t.bindings then
		t.bindings = createBindings(t)
	end

	return setmetatable(t, {
		__call = function()
			evaluateBindings(t.bindings, t)
			updateChildren(t)
			t.width, t.height = applyColumnLayoutNew(t, t.spacing)
		end
	})
end

function ui.row(t, defaults)
	t.name = "row"
	t.x = t.x or 0
	t.y = t.y or 0
	t.width = t.width or 0
	t.height = t.height or 0
	t.spacing = t.spacing or defaults and defaults.spacing or 0

	if not t.bindings then
		t.bindings = createBindings(t)
	end

	return setmetatable(t, {
		__call = function()
			evaluateBindings(t.bindings, t)
			t.width, t.height = applyRowLayout(t, t.spacing, t)
		end
	})
end

function ui.repeater(t, defaults)
	t.THIS_IS_REPEATER = ""
	t.x = t.x or 0
	t.y = t.y or 0
	t.times = t.times or 1

	--print("inspect", inspect(t))

	if not t.bindings then
		t.bindings = createBindings(t)
	end

	--print("inspect", inspect(t))

	local lastTimes = 0
	local delegate = nil

	return setmetatable(t, {
		__call = function() 
			evaluateBindings(t.bindings, t)

			if not delegate then
				delegate = t[1]
			end

			if lastTimes ~= t.times then
				--[[for index in ipairs (t) do
					print("removing", index)
				    t[index] = nil
				end--]]

				for i=1, t.times do
					print("i", i)
					local itemcopy = copy3(delegate)
					itemcopy.index = i
					print("delegate name", delegate.name)
					t[i] = ui[delegate.name](itemcopy)
					--t[i]()
				end

				lastTimes = t.times
			end
		end
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