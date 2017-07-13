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
	self.pathPoint = self.path[self.pathIndex]
	self.rotation = self:getRotationToNext(self.pathPoint, self.path[self.pathIndex+1])
	self.newRotation = self.rotation
	self.oldRotation = self.rotation
	self.oldX = self.x
	self.oldY = self.y
	self.waitTime = 0
	self.isDead = false
end

function Enemy:addToPath(point, path)
	assert(type(point) == "table", "point must be table")
	assert(type(point.x) == "number" and type(point.y) == "number", "point must contain x and y coordinates as numbers")
	assert(type(path) == "table", "path must be table")

	path[#path+1] = point
end

function Enemy:createPathPoint(x, y, mapItems, path)
	local row = mapItems[x]
	if row then
		local tile = row[y]
		if tile then
			if tile == 8 or tile == 9 then
				local point = {x=x, y=y}
				if path then
					if not self:pathContainsPoint(path, point) then
						return point
					end
				else
					return point
				end
			end
		end
	end

	return nil
end

function Enemy:areSamePathPoints(point1, point2)
	return point1.x == point2.x and point1.y == point2.y
end

function Enemy:pathContainsPoint(path, point)
	for i,v in ipairs(path) do
		pprint(v)
		if self:areSamePathPoints(v, point) then
			return true
		end
	end

	return false
end

function Enemy:computePath(startX, startY, mapItems)
	local path = {circular=false}

	local startingPoint = {x=startX, y=startY}
	self:addToPath(startingPoint, path)

	local lastDirection = nil

	local order = {
		"right",
		"top",
		"left",
		"bottom"
	}

	local opposite = {
		["right"]="left",
		["top"]="bottom",
		["left"]="right",
		["bottom"]="top",
	}

	while true do
		local possibleDirections = self:getPossibleDirections(lastPoint, mapItems, path)
		possibleDirections[opposite[lastDirection]] = nil
		
		if not lume.any(possibleDirections) then
			print("path completed")
			break
		end

		for k,direction in ipairs(order) do
			local point = possibleDirections[direction]
			if point then
				lastDirection = direction
				self:addToPath(point, path)
				break
			end
		end
	end

	return path
end

function Enemy:getPossibleDirections(currentPoint, mapItems, path)
	local cx, cy = currentPoint.x, currentPoint.y

	local possibleDirections = {
		["right"]  = self:createPathPoint(cx+1, cy, mapItems, path),
		["top"]    = self:createPathPoint(cx, cy-1, mapItems, path),
		["left"]   = self:createPathPoint(cx-1, cy, mapItems, path),
		["bottom"] = self:createPathPoint(cx, cy+1, mapItems, path),
	}

	return possibleDirections
end

function Enemy:getNextPathPoint(currentPoint, mapItems, path)
	local cx, cy = currentPoint.x, currentPoint.y

	local possibleDirections = {
		self:createPathPoint(cx+1, cy, mapItems, path),
		self:createPathPoint(cx, cy-1, mapItems, path),
		self:createPathPoint(cx-1, cy, mapItems, path),
		self:createPathPoint(cx, cy+1, mapItems, path),
	}

	possibleDirections = lume.filter(possibleDirections)

	return possibleDirections[1]
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

		if self.pathIndex == #self.path and newIndex == #self.path - 1 then
			self.waitTime = defaultWaitTime
		end

		if newIndex == 1 or newIndex == #self.path then
			self.pathStep = self.pathStep * -1
		end

		self.newRotation = self:getRotationToNext(self.path[self.pathIndex], self.path[newIndex]) or self.rotation
		self.oldRotation = self.rotation

		self.pathIndex = newIndex

		self.pathPoint = self.path[self.pathIndex]
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