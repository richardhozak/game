local util = require("util")
local lume = require("lib.lume")
local flux = require("lib.flux")
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

function Enemy:reset()
	self.timeToMove = 0
	self.pathIndex = 1
	self.pathStep = 1

	local mapItems = self.map.items
	self.path = self:computePath(self.mapX, self.mapY, mapItems)
	self.pathPoint = self.path[self.pathIndex]
	pprint(self.path)
	self.rotation = math.pi/2--self:getRotationToNext(self.pathPoint, self.path[self.pathIndex+1])
	self.newRotation = self.rotation
	self.oldRotation = self.rotation
	self.oldX = self.x
	self.oldY = self.y
	self.waitTime = 0
	self.isDead = false
	self.moveAnimation = nil
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
				return point
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

	local lastPoint = startingPoint
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
		if path.circular then
			break
		end

		local possibleDirections = self:getPossibleDirections(lastPoint, mapItems, path)
		if lastDirection then
			possibleDirections[opposite[lastDirection]] = nil
		end
		
		if not lume.any(possibleDirections)  then
			print("path completed")
			break
		end

		for k,direction in ipairs(order) do
			local point = possibleDirections[direction]
			if point then
				lastPoint = point
				lastDirection = direction
				if self:areSamePathPoints(point, startingPoint) then
					path.circular = true
				else
					self:addToPath(point, path)
				end
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
	if self.moveAnimation then
		self.moveAnimation:stop()
	end
end

function Enemy:needsToWait(dt)
	if self.waitTime > 0 then
		self.waitTime = self.waitTime - dt
		return true
	end

	return false
end

function Enemy:canMove(dt)
	self.timeToMove = self.timeToMove - dt
	if self.timeToMove <= 0 then
		self.timeToMove = defaultTimeToMove
		return true
	end

	return false
end

function Enemy:nextPathIndex(pathIndex, pathStep)
	local newPathIndex = pathIndex + pathStep
	if pathStep >= 1 then
		if newPathIndex > #self.path then
			if self.path.circular then
				newPathIndex = 1
			else
				pathStep = pathStep * -1
				newPathIndex = pathIndex + pathStep
			end
		end
	elseif pathStep <= -1 then
		if newPathIndex < 1 then
			if self.path.circular then
				newPathIndex = #self.path
			else
				pathStep = pathStep * -1
				newPathIndex = pathIndex + pathStep
			end
		end
	else
		newPathIndex = pathIndex
	end

	return newPathIndex, pathStep
end

function Enemy:getCurrentPathPosition()
	local point = self.path[self.pathIndex]
	return {x=point.x * self.tileSize, y=point.y * self.tileSize}
end

function Enemy:getRotationToPoint(startPoint, endPoint)
	local startx, starty = startPoint.x, startPoint.y
	local endx, endy = endPoint.x, endPoint.y

	if endx == startx then
		if endy < starty then
			return math.pi/2
		elseif endy > starty then
			return 3 * math.pi / 2
		end
	elseif endy == starty then
		if endx < startx then
			return math.pi
		elseif endx > startx then
			return 0
		end
	end
end

function Enemy:getRotationToNext(currentRotation, currentPoint, nextPoint)
	currentRotation = currentRotation % (math.pi*2)
	local nextRotation = self:getRotationToPoint(currentPoint, nextPoint)

	if not nextRotation then
		return currentRotation
	end

	local diff = currentRotation - nextRotation
	print(currentRotation, nextRotation, diff)


	if diff >= math.pi then
		local remainder = diff % math.pi
		return remainder * -1
	elseif diff < math.pi then
		local remainder = diff % math.pi
		return remainder * -1
	end
end

function Enemy:update(dt)
	if self.isDead or self:needsToWait(dt) then
		return
	end

	if self:canMove(dt) then
		local oldPathPoint = self.path[self.pathIndex]
		self.pathIndex, self.pathStep = self:nextPathIndex(self.pathIndex, self.pathStep)
		--print(self.pathIndex, self.pathStep)
		self.moveAnimation = flux.to(self, defaultTimeToMove, self:getCurrentPathPosition()):ease("linear"):onupdate(function() 
			self.x, self.y = self.world:move(self, self.x, self.y, self.collisionFilter) 
		end)

		local newRotation = self:getRotationToNext(self.rotation, oldPathPoint, self.path[self.pathIndex])
		flux.to(self, defaultTimeToMove, {rotation=self.rotation + newRotation})
	end
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