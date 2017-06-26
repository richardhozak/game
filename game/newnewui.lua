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
local function createBindings(bindings, context)
	for key, value in pairs(context) do
		if type(value) == "function" then
			bindings[key] = value
		elseif type(value) == "table" and value ~= bindings and type(key) ~= "number" then
			print(key, type(key))
			local subbindings = {}
			bindings[key] = subbindings
			createBindings(subbindings, value)
		end
	end
end

local function evaluateBindings(bindings, context, arg)
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
	print("t", t.x, t.x, t.width, t.height)
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
		t.bindings = {}
		createBindings(t.bindings, t)
	end

	local pressedRegistered = false

	return setmetatable(t, {
		__call = function()
			local mx, my = love.mouse.getPosition()
			t.mouseover = pointInRect(mx, my, t.x, t.y, t.width, t.height)
			
			--[[for key, value in pairs(t.bindings) do
				if type(value) == "function" then
					t[key] = value(t)
				end
			end--]]

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

function ui.column(t, defaults)
	t.name = "column"
	t.x = t.x or 0
	t.y = t.y or 0
	t.spacing = t.spacing or defaults and defaults.spacing or 0

	return setmetatable(t, {
		__call = function()
			local width = 0
			local height = 0
			for index, child in ipairs(t) do
				child.parent = t
				child.y = t.y + height
				child.x = t.x

				child()
				
				height = height + child.height + (index == #t and 0 or t.spacing)

				if child.width > width then
					width = child.width
				end
			end
			
			t.width = width
			t.height = height
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

	t.bindings = {}
	createBindings(t.bindings, t)

	print(inspect(t))

	return setmetatable(t, {
		__call = function()
			local width = 0
			local height = 0

			evaluateBindings(t.bindings, t)

			for index, child in ipairs(t) do
				child.parent = t
				child.x = t.x + width
				child.y = t.y
				
				child()
				
				width = width + child.width + (index == #t and 0 or t.spacing)

				if child.height > height then
					height = child.height
				end
			end
			
			t.width = width
			t.height = height
		end
	})
end

function ui.repeater(t, defaults)
	t.name = "repeater"
	t.x = t.x or 0
	t.y = t.y or 0
	t.height = 0
	t.width = 0
	t.times = t.times or 1
	t.parent = nil

	print("inspect", inspect(t))

	t.bindings = {}
	createBindings(t.bindings, t)

	print("inspect", inspect(t))

	local initialized = false
	local update = nil
	local lastTimes = 0

	return setmetatable(t, {
		__call = function() 
			evaluateBindings(t.bindings, t)

			print(t.times)

			if lastTimes ~= t.times then
				local item = t[1]
				local name = item.name

				for i=1, t.times do
					local itemcopy = copy3(item)
					itemcopy.index = i
					t[i] = ui[name](itemcopy)
				end

				if update then
					print("update set")
				else
					update = ui[t.parent.name](t, t.parent)
				end

				lastTimes = t.times
			end

			update()
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