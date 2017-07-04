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

function util.emit(func)
	if type(func) == "function" then
		func()
	end
end

function util.lightness(color)
  --return (0.299*color[1] + 0.587*color[2] + 0.114*color[3]) / 255
  local r, g, b = color[1], color[2], color[3]
  return ((r+r+b+g+g+g)/6)/255
end

function util.brightness(color)
	local r, g, b = color[1], color[2], color[3]
	return math.sqrt(r*r*0.241 + g*g*0.691 + b*b*0.068)
end

local function components()
	local variables = {}
	local id = 1
	while true do 
		local index, value = debug.getlocal(2, id)
		if index then
			if type(value) == "table" and value.name then
				print("local table", value.name, value, index)
				variables[value.name] = value
			end
		else
			break
		end
		id = id + 1
	end
	return variables
end

return util

-- creates bindings table from functions that are present in 'context' table (recursively)
-- local function createBindings(context)
-- 	local bindings = nil
-- 	for key, value in pairs(context) do
-- 		if type(value) == "function" then
-- 			if not bindings then bindings = {} end
-- 			bindings[key] = value
-- 		elseif type(value) == "table" and value ~= bindings and type(key) ~= "number" then
-- 			local subbindings = createBindings(value)
-- 			if subbindings then
-- 				if not bindings then bindings = {} end
-- 				bindings[key] = subbindings
-- 			end
-- 		end
-- 	end

-- 	return bindings
-- end

-- local function evaluateBindings(bindings, context, arg)
-- 	if not bindings then return end
-- 	if not arg then
-- 		arg = context
-- 	end

-- 	for key, value in pairs(bindings) do
-- 		if type(value) == "function" then
-- 			context[key] = value(arg)
-- 		elseif type(value) == "table" then
-- 			--print("evaluating", key, value, inspect(value), inspect(context[key]))
-- 			evaluateBindings(value, context[key], arg)
-- 		end
-- 	end
-- end
