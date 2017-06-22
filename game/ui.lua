local Object = require("lib.classic")
local Ui = Object:extend()

function Ui:new(t)
	t.x = 0
	t.y = 0
	self.content = t
end

function Ui:button(t)
	t.name = "button"
	return t
end

function Ui:column(t)
	t.name = "column"
	t.y = t.y or 0
	t.x = t.x or 0

	local spacing = t.spacing or 0
	local height = 0
	local width = 0
	for index, item in ipairs(t) do
		print(index, type(item) == "table" and item.name or item, type(item))

		item.y = t.y + height
		item.x = t.x
		height = height + item.height + spacing
		
		if item.width > width then
			width = item.width
		end
	end

	t.height = height
	t.width = width

	return t
end

function Ui:row(t)
	t.name = "row"
	t.y = t.y or 0
	t.y = t.y or 0

	local spacing = t.spacing or 0
	local height = 0
	local width = 0

	for index, item in ipairs(t) do
		print(index, type(item) == "table" and item.name or item, type(item))
		item.y = t.y
		item.x = t.x + width
		width = width + item.width + spacing

		if item.height > height then
			height = item.height
		end
	end

	t.height = height
	t.width = width

	return t
end

function Ui:update(dt)
end

function Ui:drawItem(t)
	for index, item in ipairs(t) do
		print(type(item))
		if type(item) == "function" then
			item(t.x, t.y)
		elseif item.name == "column" or item.name == "row" then
			self:drawItem(item)
		elseif item.name == "button" then
			love.graphics.setColor(item.color)
			love.graphics.rectangle("fill", item.x, item.y, item.width, item.height)
		end
	end
end

function Ui:draw()
	self:drawItem(self.content)
end

function Ui:rowFunc(t)
	t.name = "rowFunc"
	return function(x, y)
		local width = 0
		local height = 0
		local spacing = t.spacing or 0

		for index, item in ipairs(t) do
			print(index, type(item) == "table" and item.name or item, type(item))

			item.y = y
			item.x = x + width
			width = width + item.width + spacing

			if item.height > height then
				height = item.height
			end
		end

		t.width = width
		t.height = height
	end
end

return Ui