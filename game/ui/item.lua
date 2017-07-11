local Item = {}
Item.__index = Item
Item.hotitem = nil

function Item:new()
    self.x = self.x or 0
    self.y = self.y or 0
    if self.visible == nil then
        self.visible = true
    end
    if self.enabled == nil then
        self.enabled = true
    end
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
    print("creating bindings")
    local bindings = nil
    
    for key, value in pairs(self) do
        if type(value) == "function" then
            if not bindings then bindings = {} end
            bindings[key] = value
        elseif type(value) == "table" and value ~= bindings and type(key) ~= "number" then
            local subbindings = Item.createBindings(value)
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
        if child.visible then
            child:draw()
        end
    end
end

function Item:containsPoint(x, y)
    return x > self.x and x < self.x + self.width 
       and y > self.y and y < self.y + self.height
end

function Item:mousePressed(x, y, button, istouch)
    if self:containsPoint(x, y) then
        for i=#self, 1, -1 do
            local item = self[i]
            if item:containsPoint(x, y, button, istouch) then
                if item:mousePressed(x, y, button, istouch) then
                    return true
                end
            end
        end
    end

    return false
end

function Item:mouseReleased(x, y, button, istouch)
    for i=#self, 1, -1 do
        local item = self[i]
        if item:mouseReleased(x, y, button, istouch) then
            return true
        end
    end

    return false
end

function Item:mouseMoved(x, y, dx, dy, istouch)
    local mouseover = false

    for i=#self, 1, -1 do
        local item = self[i]
        if item:mouseMoved(x, y, button, istouch) then
            mouseover = true
        end
    end

    if self.name == "button" or self.name == "input" then
        self.mouseover = self:containsPoint(x, y)
    end

    if self.mouseover then
        mouseover = true
    end

    return mouseover
end

function Item:textInput(text)
    if not self.enabled then
        return false
    end

    for i=#self, 1, -1 do
        local item = self[i]
        if item:textInput(text) then
            return true
        end
    end
end

function Item:keyReleased(key, scancode)
    if not self.enabled then
        return false
    end

    for i=#self, 1, -1 do
        local item = self[i]
        if item:keyReleased(key, scancode) then
            return true
        end
    end

    return false
end

function Item:keyPressed(key, scancode, isrepeat)
    if not self.enabled then
        return false
    end

    for i=#self, 1, -1 do
        local item = self[i]
        if item:keyPressed(key, scancode, isrepeat) then
            return true
        end
    end

    return false
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
