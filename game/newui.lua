local ui = {}

local function pointInRect(px, py, rx, ry, rw, rh)
	return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
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

	local bindings = {}	

	for index, value in pairs(t) do
		if type(value) == "function" then
			bindings[index] = value
			t[index] = value(t)
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

function ui.column(t)
	t.name = "column"
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
				item = update()
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
				item = update()
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
			if item.name == "button" then
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