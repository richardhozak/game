local Item = {}
Item.__index = Item

function Item:new()
end

function Item:extend(name)
    if not name then error("must supply name") end
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
