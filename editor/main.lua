local util = require("util")
local bump = require("lib.bump")

local width, height
local tileSize
local camera = require("camera")
local cameraX, cameraY
local beginX, beginY
local world
local axisLocked

local lastColumn
local lastRow
local axisDirection

function love.load()
    love.window.setMode(800, 600, {x=1120, 
                                   y=25, 
                                   resizable=true, 
                                   minwidth=640, 
                                   minheight=480})

    local screenW, screenH = love.graphics.getDimensions()
    width = 32
    height = 32
    tileSize = 32
    camera:setRegion(0, 0, width * tileSize, height * tileSize)
    beginX, beginY = 0
    world = bump.newWorld(50)
    axisLocked = false
end

function love.update(dt)
    if love.mouse.isDown(2) then
        local mouseX, mouseY = love.mouse.getPosition()
        local diffX = mouseX - beginX
        local diffY = mouseY - beginY
        diffX = -diffX
        diffY = -diffY
        camera:setPosition(cameraX + diffX, cameraY + diffY)
    end

    if love.mouse.isDown(1) then
        local mouseX, mouseY = camera:getMousePosition()
        local column = math.floor(mouseX / tileSize)
        local row = math.floor(mouseY / tileSize)

        if love.keyboard.isDown("lshift") then
            if not lastColumn and not lastRow then
                print("setting position", lastColumn, lastRow)
                lastColumn, lastRow = column, row
                axisDirection = nil
            elseif not axisDirection then
                local horizontalDiff = math.abs(lastColumn - column) > 0
                local verticalDiff = math.abs(lastRow - row) > 0

                if horizontalDiff and verticalDiff then
                    -- diagonal dragging not supported
                    goto continue
                elseif horizontalDiff then
                    axisDirection = "horizontal"
                elseif verticalDiff then
                    axisDirection = "vertical"
                else
                    print("no movement")     
                end
                print("setting axis direction", axisDirection)
                goto continue
            else
                local horizontalDiff = math.abs(lastColumn - column) > 0
                local verticalDiff = math.abs(lastRow - row) > 0
                
                if axisDirection == "horizontal" then
                    if verticalDiff then
                        row = lastRow
                    end
                elseif axisDirection == "vertical" then
                    if horizontalDiff then
                        column = lastColumn
                    end
                --[[
                elseif axisDirection == "diagonal" then
                    if not horizontalDiff and not vertical then
                        goto continue
                    end
                --]]
                else
                    error("invalid axis direction", axisDirection)
                end
            end
        end

        local items, len = world:queryPoint(mouseX, mouseY)
        if len == 0 then
            print("adding", column, row)
            local item = {x=column * tileSize, y=row * tileSize}
            world:add(item, item.x, item.y, tileSize, tileSize)
        end
        --local items, len = world:queryPoint
    end

    ::continue::

    camera:update(dt)
    --print(camera.x, " ", camera.y)
end

local function drawBackground(x,y,w,h)
    local beginX = math.floor(x / tileSize) * tileSize
    local beginY = math.floor(y / tileSize) * tileSize
    local horizontalCount = math.ceil(w / tileSize) + 1
    local verticalCount = math.ceil(h / tileSize) + 1
    local xEven = math.floor(x / tileSize) % 2 == 0
    local yEven = math.floor(y / tileSize) % 2 == 0
    local evenOffset = (xEven and 1 or 0) + (yEven and 1 or 0)

    love.graphics.push()
    love.graphics.translate(beginX, beginY)
    for i=1, horizontalCount do
        for j=1, verticalCount do
            local x = (i-1)*tileSize
            local y = (j-1)*tileSize
            local isEven = ((i + j + evenOffset) % 2 == 0)
            local color = isEven and {52,52,52} or {65,65,65}
            love.graphics.setColor(color)
            love.graphics.rectangle("fill", x, y, tileSize, tileSize)
        end
    end
    love.graphics.pop()
end

local function drawWorld()
    love.graphics.setColor(255,255,255,255)
    local items, len = world:getItems()
    for i=1, len do
        local item = items[i]
        love.graphics.rectangle("fill", item.x, item.y, tileSize, tileSize)
    end
end

function love.draw()
    camera:draw(function(x,y,w,h)
        drawBackground(x,y,w,h)
        drawWorld()
    end)
end

function love.mousepressed(x, y, button, istouch)
    if button == 2 or button == 1 then
        cameraX = camera.posX
        cameraY = camera.posY
        beginX, beginY = x, y
        print("dragstart", x,y,button)
    end
end

function love.mousereleased(x, y, button, istouch)
    if button == 2 or button == 1 then
        beginX, beginY = nil, nil
        lastColumn, lastRow = nil, nil
        axisDirection = nil
        print("dragended",x,y,button)
    end
end

function love.keypressed(key, scancode, isrepeat)
    print("pressed ", key, scancode)
end

function love.keyreleased(key, scancode)
    print("released", key, scancode)
end