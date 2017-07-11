local util = require("util")
local lume = require("lib.lume")
local Entity = require("entities.entity")

local Enemy = Entity:extend()

local defaultTimeToMove = 0.5
local defaultWaitTime = 1

function Enemy:new(world, mapX, mapY, x, y, width, height, map, tileSize)
	Enemy.super.new(self, world, x, y, width, height)
	self.mapX, self.mapY = mapX, mapY
	self.tileSize = tileSize
	self.map = map
	self:reset()
end

function Enemy:collisionFilter(other)
    return "cross"
end

function Enemy:tileAtCoords(items, mapX, mapY)
	local col = items[mapX]
	if col then
		return col[mapY]
	else
		print("col is nil")
	end
end

function Enemy:addToPath(path, x, y)
	assert(type(path) == "table", "path needs to be table")
	
	if not path[x] then
		path[x] = {}
	end

	if path[x][y] then
		return false
	end

	if not path.points then
		path.points = {}
	end

	table.insert(path.points, {x=x,y=y})
	
	path[x][y] = #path.points

	return true
end

function Enemy:getRotationToNext(currentPoint, nextPoint)
	local cx, cy = currentPoint.x, currentPoint.y
	local nx, ny = nextPoint.x, nextPoint.y

	if nx == cx then
		if ny < cy then
			return math.pi/2
		elseif ny > cy then
			return 3 * math.pi / 2
		end
	elseif ny == cy then
		if nx < cx then
			return math.pi
		elseif nx > cx then
			return 0
		end
	end
end

function Enemy:reset()
	self.timeToMove = 0
	self.pathIndex = 1
	self.pathStep = 1

	local mapItems = self.map.items
	self.path = self:computePath(self.mapX, self.mapY, mapItems)
	self.pathPoint = self.path.points[self.pathIndex]
	self.rotation = self:getRotationToNext(self.pathPoint, self.path.points[self.pathIndex+1])
	self.newRotation = self.rotation
	self.oldRotation = self.rotation
	self.oldX = self.x
	self.oldY = self.y
	self.waitTime = 0
	self.isDead = false
end

function Enemy:computePath(mapX, mapY, mapItems, path)
	if not path then
		path = {}
	end

	if not self:addToPath(path, mapX, mapY) then
		return path
	end

	local pathTop = self:tileAtCoords(mapItems, mapX, mapY-1) == 9
	if pathTop then
		self:computePath(mapX, mapY-1, mapItems, path)
	end

	local pathLeft = self:tileAtCoords(mapItems, mapX-1, mapY) == 9
	if pathLeft then
		self:computePath(mapX-1, mapY, mapItems, path)
	end

	local pathBottom = self:tileAtCoords(mapItems, mapX, mapY+1) == 9
	if pathBottom then
		self:computePath(mapX, mapY+1, mapItems, path)
	end
	
	local pathRight = self:tileAtCoords(mapItems, mapX+1, mapY) == 9
	if pathRight then
		self:computePath(mapX+1, mapY, mapItems, path)
	end

	return path
end

function Enemy:hit()
	self.isDead = true
end

function Enemy:update(dt)
	if self.isDead then
		return
	end

	if self.waitTime > 0 then
		self.waitTime = self.waitTime - dt
		return
	end

	self.timeToMove = self.timeToMove - dt
	if self.timeToMove <= 0 then
		self.timeToMove = defaultTimeToMove

		local newIndex = self.pathIndex + self.pathStep

		if self.pathIndex == 1 and newIndex == 2 then
			self.waitTime = defaultWaitTime
		end

		if self.pathIndex == #self.path.points and newIndex == #self.path.points - 1 then
			self.waitTime = defaultWaitTime
		end

		if newIndex == 1 or newIndex == #self.path.points then
			self.pathStep = self.pathStep * -1
		end

		self.newRotation = self:getRotationToNext(self.path.points[self.pathIndex], self.path.points[newIndex])
		self.oldRotation = self.rotation

		self.pathIndex = newIndex

		self.pathPoint = self.path.points[self.pathIndex]
		self.oldX = self.x
		self.oldY = self.y
	end

	local destinationProgress = 1-(self.timeToMove/defaultTimeToMove)
	local destX = self.pathPoint.x*self.tileSize
	local destY = self.pathPoint.y*self.tileSize
	local x = lume.lerp(self.oldX, destX, destinationProgress)
	local y = lume.lerp(self.oldY, destY, destinationProgress)

    self.x, self.y = self.world:move(self, x, y, self.collisionFilter)
    self.rotation = lume.lerp(self.oldRotation, self.newRotation, destinationProgress*3)
end

function Enemy:draw()
	local x, y = self:getCenter()
	local radius = self.width / 2 * 0.75
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(-self.rotation)
	if self.isDead then
		util.drawFilledCircle(0, 0, radius, 200, 200, 200)
	else
		util.drawFilledCircle(0, 0, radius, 207, 0, 15)
	end
	util.drawFilledCircle(radius*0.75, -radius / 2, 5, 255, 255, 255)
	util.drawFilledCircle(radius*0.75, radius / 2, 5, 255, 255, 255)
	love.graphics.pop()
end

return Enemy