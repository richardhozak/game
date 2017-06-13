local util = require("util")
local bump = require("lib.bump")
local luatable = require("lib.LuaTable")

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

local dialogVisible
local mapName
local saveDir
local font

local help = [[
right mouse - move map
left mouse - draw tile
mouse wheel - change tile
1-9 key - select tile
]]

local tiles = {
    {name="blank", color={228,241,254}},
    {name="wall", color={103,128,159}},
    {name="glass", color={25,181,254}},
    {name="door", color={192,52,43}},
    {name="start", color={245,171,53}},
    {name="end", color={38,194,129}},
}
local selectedTileIndex = 1

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
    dialogVisible = true
    mapName = ""
    saveDir = love.filesystem.getSaveDirectory()
    font = love.graphics.getFont()
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

    if dialogVisible then
        camera:update(dt)
        return
    end

    if love.mouse.isDown(1) then
        local mouseX, mouseY = camera:getMousePosition()
        local column = math.floor(mouseX / tileSize)
        local row = math.floor(mouseY / tileSize)
        local allowDraw = true

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
                    allowDraw = false
                elseif horizontalDiff then
                    axisDirection = "horizontal"
                elseif verticalDiff then
                    axisDirection = "vertical"
                else
                    print("no movement")
                end

                print("setting axis direction", axisDirection)
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
                else
                    print("invalid axis direction", axisDirection)
                    allowDraw = false
                end
            end
        end

        if allowDraw then
            local items, len = world:queryPoint(mouseX, mouseY)
            local tile = tiles[selectedTileIndex]
            for i=1, len do
                world:remove(items[i])
            end

            if tile.name ~= "blank" then
                local item = {x=column * tileSize, y=row * tileSize, index=selectedTileIndex}
                world:add(item, item.x, item.y, tileSize, tileSize)
            end
        end
    end

    camera:update(dt)
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
        local tile = tiles[item.index]
        love.graphics.setColor(tile.color)
        love.graphics.rectangle("fill", item.x, item.y, tileSize, tileSize)
    end
end

local function drawTileIcon(margin, padding, width, height, index, text, rgba, selected)
    love.graphics.push()

    love.graphics.translate(margin, margin)
    local width = width - 2*margin

    if selected then
        util.drawFilledRectangle(0,0,width,width, 200,200,200)
    end

    do
        love.graphics.push()
        
        love.graphics.translate(padding, padding)
        local width = width - 2*padding

        util.drawFilledRectangle(0,0,width,width, unpack(rgba))
        love.graphics.setColor(255,255,255)
        love.graphics.print(text)

        love.graphics.print(index, width/2-font:getWidth(index)/2,width/2-font:getHeight()/2)

        love.graphics.pop()
    end

    love.graphics.pop() 
end

local function drawUi(x, y)
    local margin = 10
    local padding = 10
    local width = 100
    local screenHeight = love.graphics.getHeight()
    local height = #tiles * width - (#tiles-1) * (margin+padding)
    local maxY = y + selectedTileIndex * width - (selectedTileIndex-1)*(margin+padding)

    local yOffset = screenHeight - y - maxY

    if yOffset > 0 then
        yOffset = 0
    end

    do 
        love.graphics.push()
        love.graphics.translate(x, y+yOffset)
        util.drawFilledRectangle(0, 0, width, height, 102, 51, 153)

        love.graphics.push()
        for index, tile in ipairs(tiles) do
            drawTileIcon(margin, padding, width, width, index, tile.name, tile.color, index == selectedTileIndex)
            love.graphics.translate(0, width-margin-padding)
        end
        love.graphics.pop()

            
        love.graphics.pop() 
    end
end

local function drawDialog()
    local x,y = 0,0
    local width, height = love.graphics.getDimensions()

    local dialogWidth = 270
    local dialogHeight = 70
    local dialogX = (width - dialogWidth) / 2
    local dialogY = (height - dialogHeight) / 2
    local margin = 20

    love.graphics.setColor(0,0,0,100)
    love.graphics.rectangle("fill", x, y, width, height)

    love.graphics.setColor(0,0,0,150)
    love.graphics.rectangle("fill", dialogX, dialogY, dialogWidth, dialogHeight, 10, 10)

    love.graphics.setColor(255,255,255)
    love.graphics.print("Enter name of map (confirm with Enter)", dialogX + 5, dialogY)

    do
        love.graphics.push()
        local width, height = dialogWidth - margin*2, dialogHeight - margin*2
        love.graphics.translate(dialogX + margin, dialogY + margin)
        love.graphics.rectangle("fill", 0, 0, width, height, 5, 5)

        love.graphics.setColor(0,0,0,255)
        love.graphics.print(mapName, 5, (height - font:getHeight()) / 2)
        love.graphics.pop()
    end
end

function love.draw()
    camera:draw(function(x,y,w,h)
        drawBackground(x,y,w,h)
        drawWorld()
    end)

    drawUi(0,0)
    if dialogVisible then
        drawDialog()
    end

    local width, height = love.graphics.getDimensions()

    love.graphics.setColor(255,255,255,255)
    love.graphics.print("savedir: " .. saveDir, 0, height - font:getHeight())

    love.graphics.printf(help,width - 200,0,200,"right")
end

function love.wheelmoved(x, y)
    if y > 0 then
        local newIndex = selectedTileIndex - 1
        if newIndex >= 1 then
            selectedTileIndex = newIndex
        end
    elseif y < 0 then
        local newIndex = selectedTileIndex + 1
        if newIndex <= #tiles then
            selectedTileIndex = newIndex
        end
    end
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

local function loadWorld(items)
    for index, item in ipairs(items) do
        world:add(item, item.x, item.y, tileSize, tileSize)
    end
end

function love.keypressed(key, scancode, isrepeat)
    local num = tonumber(scancode)
    print("pressed ", key, scancode, num)

    if dialogVisible then
        if scancode == "backspace" then
            mapName = mapName:sub(1, -2)
        elseif scancode == "return" then
            if #mapName > 0 then
                mapName = mapName .. ".lua"
                if love.filesystem.exists(mapName) then
                    local chunk = love.filesystem.load(mapName)
                    loadWorld(chunk())
                end

                dialogVisible = false
            end
        elseif #scancode == 1 and #mapName < 20 then
            if string.match(scancode, "[0-9]") or string.match(scancode, "[a-z]") then
                mapName = mapName .. scancode
            end
        end
        
        return
    end

    if key == "s" and love.keyboard.isDown("lctrl") then
        local file, errorstr = love.filesystem.newFile(mapName, "w")
        if file then
            print("saving file")
            local items, len = world:getItems()
            local encoded = luatable.encode(items)
            file:write(encoded)
            file:close()
        else
            error(errorstr)
        end
    end

    if num and num >= 1 and num <= #tiles then
        selectedTileIndex = num
    end
end

function love.keyreleased(key, scancode)
    print("released", key, scancode)
end