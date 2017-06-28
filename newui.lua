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

function ui.item(t)
	t.name = "item"
	t.x = t.x or 0
	t.y = t.y or 0

	return function()
		return t
	end
end

function ui.button(t)
	t.name = "button"
	t.x = t.x or 0
	t.y = t.y or 0
	t.radius = t.radius or 0

	if t.border then
		t.border.width = t.border.width or 0
		t.border.color = t.border.color or {0,0,0,0}
	end

	local initialized = false
	local bindings = {}	
	local pressedRegistered = false

	return function(ret)
		if ret then 
			return t
		end

		if not initialized then
			for index, value in pairs(t) do
				if type(value) == "function" then
					bindings[index] = value
					t[index] = value(t)
				end
			end

			initialized = true
		end

		local mx, my = love.mouse.getPosition()
		t.mouseOver = pointInRect(mx, my, t.x, t.y, t.width, t.height)
		for index, value in pairs(bindings) do
			t[index] = value(t)
		end

		if t.mouseOver and love.mouse.isDown(1) then
			t.pressed = true
			if not pressedRegistered then
				pressedRegistered = true
				local onPressed = t["onPressed"]
				if onPressed then onPressed() end
			end
		elseif t.pressed then
			t.pressed = false
			pressedRegistered = false

			local onClicked = t["onClicked"]
			if onClicked then onClicked() end

			local onReleased = t["onReleased"]
			if onReleased then onReleased() end
		end

		return t
	end
end

function ui.oldbutton(t)
	t.name = "button"
	t.x = t.x or 0
	t.y = t.y or 0
	t.radius = t.radius or 0

	if t.border then
		t.border.width = t.border.width or 0
		t.border.color = t.border.color or {0,0,0,0}
	end

	local bindings = {}	

	for index, value in pairs(t) do
		if type(value) == "function" then
			bindings[index] = value
			--t[index] = value(t)
		end
	end

	local pressedRegistered = false

	return function()
		local mx, my = love.mouse.getPosition()
		t.mouseOver = pointInRect(mx, my, t.x, t.y, t.width, t.height)
		for index, value in pairs(bindings) do
			t[index] = value(t)
		end

		if t.mouseOver and love.mouse.isDown(1) then
			t.pressed = true
			if not pressedRegistered then
				pressedRegistered = true
				local onPressed = t["onPressed"]
				if onPressed then onPressed() end
			end
		elseif t.pressed then
			print("asd")
			t.pressed = false
			pressedRegistered = false

			local onClicked = t["onClicked"]
			if onClicked then onClicked() end

			local onReleased = t["onReleased"]
			if onReleased then onReleased() end
		end

		return t
	end
end


function ui.repeater(t)
	print("creating repeater")
	t.name = "repeater"
	t.x = t.x or 0
	t.y = t.y or 0
	t.height = 0
	t.width = 0
	t.times = t.times or 1

	local initialized = false

	--[[local itemtable = {}
	local delegate = t.delegate
	local item = delegate(t)
	local name = item.name

	for i=1, t.times do
		print("copying")
		local itemcopy = copy1(item)
		itemcopy.index = i
		print("copied")
		t[i] = ui[name](itemcopy)
		print("adasd")
	end
	--]]

	--[[
	local upd = t.updater(t)

	print("updater", t.updater)

	return upd
	--]]

	local update = nil

	return function(init)
		if init and not initialized then
			print("init name", init.name)

			local itemtable = {}
			local delegate = t.delegate
			local item = delegate(t)
			local name = item.name

			for i=1, t.times do
				local itemcopy = copy1(item)
				itemcopy.index = i
				t[i] = ui[name](itemcopy)
			end

			update = ui[init.name](t, init)
			--t.spacing = init.spacing
			initialized = true
		end

		update()

		return t
	end
end

function ui.column(t, defaults)
	t.name = "column"
	t.x = t.x or 0
	t.y = t.y or 0
	t.children = {}
	t.spacing = t.spacing or defaults and defaults.spacing or 0
	return function()
		local width = 0
		local height = 0
		local spacing = t.spacing or 0
		for index, update in ipairs(t) do
			local item = t.children[index]
			if not item then
				item = update(t)
				t.children[index] = item
			end

			item.y = t.y + height
			item.x = t.x
			height = height + item.height + (index == #t and 0 or spacing)

			if item.width > width then
				width = item.width
			end

			update()
		end

		t.width = width
		t.height = height

		return t
	end
end

function ui.row(t)
	t.name = "row"
	t.x = t.x or 0
	t.y = t.y or 0
	t.children = {}
	return function()
		local width = 0
		local height = 0
		local spacing = t.spacing or 0
		for index, update in ipairs(t) do
			local item = t.children[index]
			if not item then
				item = update(t)
				t.children[index] = item
			end

			item.x = t.x + width
			item.y = t.y
			width = width + item.width + (index == #t and 0 or spacing)

			if item.height > height then
				height = item.height
			end

			update()
		end
		
		t.width = width
		t.height = height

		return t
	end
end

function ui.render(t)
	for index, itemFunc in ipairs(t) do
		local item = itemFunc()
		t[index] = item
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