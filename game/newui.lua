local ui = {}

function ui.item(t)
	t.name = "item"
	t.x = t.x or 0
	t.y = t.y or 0

	return function(x, y)
		t.x = x or 0
		t.y = y or 0

		return t
	end
end

function ui.button(t)
	t.name = "button"
	t.color = t.color or {255,255,255}
	return function(x, y)
		t.x = x or 0
		t.y = y or 0

		return t
	end
end

function ui.column(t)
	t.name = "column"
	return function(x, y)
		x = x or 0
		y = y or 0
		local width = 0
		local height = 0
		local spacing = t.spacing or 0
		for index, itemFunc in ipairs(t) do
			local item = itemFunc(x, y+height)
			t[index] = item
			height = height + item.height + (index == #t and 0 or spacing)

			if item.width > width then
				width = item.width
			end
		end

		t.width = width
		t.height = height

		return t
	end
end

function ui.row(t)
	t.name = "row"
	return function(x, y)
		x = x or 0
		y = y or 0
		local width = 0
		local height = 0
		local spacing = t.spacing or 0
		for index, itemFunc in ipairs(t) do
			local item = itemFunc(x+width, y)
			t[index] = item
			width = width + item.width + (index == #t and 0 or spacing)

			if item.height > height then
				height = item.height
			end
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
		print(index, type(item) == "table" and item.name or item, type(item))
		if type(item) == "table" then
			if item.name == "button" then
				love.graphics.setColor(item.color)
				love.graphics.rectangle("fill", item.x, item.y, item.width, item.height)
			else
				ui.draw(item)
			end
		end
	end
end

return ui