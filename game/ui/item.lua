local Item = {}
Item.__index = Item

function Item:new()
end

local function updateChildren(t, root)
    root = root or t
    for index, child in ipairs(t) do
        if child.name then
            child.parent = root
            child:update()
        else
            if type(child.update) == "function" then
                child:update()
            else
                updateChildren(child, root)
            end
        end
    end
end

function Item:createBindings()
    local bindings = nil
    
    for key, value in pairs(self) do
        if type(value) == "function" then
            if not bindings then bindings = {} end
            bindings[key] = value
        elseif type(value) == "table" and value ~= bindings and type(key) ~= "number" then
            local subbindings = self.createBindings(value)
            if subbindings then
                if not bindings then bindings = {} end
                bindings[key] = subbindings
            end
        end
    end

    return bindings
end

function Item:evaluateBindings(bindings, context)
    if not bindings then return end
    if not context then context = self end

    for key, value in pairs(bindings) do
        if type(value) == "function" then
            context[key] = value(self)
        elseif type(value) == "table" then
            self:evaluateBindings(value, context[key])
        end
    end
end

function Item:update()
    updateChildren(self)
end

function Item:layout()
    for index, child in ipairs(self) do
        child:layout()
    end
end

function Item:draw()
    for index, child in ipairs(self) do
        child:draw()
    end
end

function Item:containsPoint(x, y)
    return x > self.x and x < self.x + self.width 
       and y > self.y and y < self.y + self.height
end

function Item:mousePressed(x, y, button, istouch)
    if self:containsPoint(x, y) and button == 1 then
        for i=#self, 1, -1 do
            local item = self[i]
            if item:mousePressed(x, y, button, istouch) then
                return true
            end
        end

        if self.name == "button" then
            self.down = true
            return true
        end
    end

    return false
end

function Item:mouseReleased(x, y, button, istouch)
    if self.down then
        self.down = false
        return true
    else
        for i=#self, 1, -1 do
            local item = self[i]
            if item:mouseReleased(x, y, button, istouch) then
                return true
            end
        end

        return false
    end
end

function Item:mouseMoved(x, y, dx, dy, istouch)
    if love.mouse.isDown(1) or love.mouse.isDown(2) then
        return false
    end

    local mouseover = false

    for i=#self, 1, -1 do
        local item = self[i]
        if item:mouseMoved(x, y, button, istouch) then
            mouseover = true
        end
    end

    if self.name == "button" then
        self.mouseover = self:containsPoint(x, y)
    end

    if self.mouseover then
        mouseover = true
    end

    return mouseover
end

function Item:extend(name)
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end
    cls.__index = cls
    cls.super = self
    cls.name = name
    setmetatable(cls, self)
    return cls
end

function Item:__tostring()
    return self.name or "Unknown"
end

function Item:__call(t)
    if type(t) ~= "table" then error("must supply table") end
    local item = setmetatable(t, self)
    item:new()
    return item
end

return Item
