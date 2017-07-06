local utf8 = require("utf8")
local util = {}

function util.calculateSpacing(spacing, itemsize, index, count)
	assert(tonumber(spacing), "invalid spacing value")
	assert(tonumber(itemsize), "invalid itemsize value")
	assert(tonumber(index), "invalid index value")
	assert(tonumber(count), "invalid count value")
	assert(index >= 1 and index <= count, "index must be in range from 1 to count")

	if index == count then
		if itemsize == 0 then
			return -spacing
		else
			return 0
		end
	elseif itemsize == 0 then
		return 0
	else
		return spacing
	end
end

function util.clearArray(t)
	for index, value in ipairs(t) do
		t[index] = nil
	end
end

-- deep-copy a table
function util.clone(t)
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = util.clone(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

function util.emit(func, ...)
	if type(func) == "function" then
		func(...)
	end
end

function util.lightness(color)
  local r, g, b = color[1], color[2], color[3]
  return ((r+r+b+g+g+g)/6)/255
end

function util.brightness(color)
	local r, g, b = color[1], color[2], color[3]
	return math.sqrt(r*r*0.241 + g*g*0.691 + b*b*0.068)
end

util.text = {}

function util.text.removeAt(text, position)
	local byteoffset = utf8.offset(text, position)
	local left = nil
	local right = nil

    if byteoffset then
    	left = string.sub(text, 1, byteoffset - 1)
    	right = string.sub(text, byteoffset)
    end

    byteoffset = utf8.offset(right, 2)

    if byteoffset then
        right = string.sub(right, byteoffset)
   	end

   	return left .. right
end

function util.text.insertAt(text, insert, position)
	local maxlen = utf8.len(text)
	local insertAtEnd = position == maxlen

	if insertAtEnd then
		return text .. insert
	else
		local byteoffset = utf8.offset(text, position+1)
		local left = nil
		local right = nil
 
	    if byteoffset then
	    	left = string.sub(text, 1, byteoffset - 1)
	    	right = string.sub(text, byteoffset)
	    end

	    return table.concat{left, insert, right}
	end
end

function util.clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end

return util
