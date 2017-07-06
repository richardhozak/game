local requiredir = (...):match("(.-)[^%.]+$")
local function requireitem(item) return require(requiredir .. item) end

local Item = requireitem("item")
local util = requireitem("util")

local Repeater = Item:extend()
function Repeater:new()
	self.super.new(self)
	self.width = width or 0
	self.height = height or 0
	self.times = self.times or 0
	self.lastTimes = self.lastTimes or 0
	self.bindings = self:createBindings()
	self.delegate = self[1]
	util.clearArray(self)
end

function Repeater:update()
	self:evaluateBindings(self.bindings)

	if self.times < 0 then
		self.times = 0
	end

	if self.times ~= self.lastTimes then
		if self.times > self.lastTimes then
			local appendTimes = self.times - self.lastTimes
			for i=1, appendTimes do
				local item = util.clone(self.delegate)
				local index = #self+1
				item.index = index
				self[index] = item
			end
		elseif self.times < self.lastTimes then
			local removeTimes = self.lastTimes - self.times
			for i=1, removeTimes do
				self[#self] = nil
			end
		end

		self.lastTimes = self.times
	end

	self.super.update(self)
end

return Repeater