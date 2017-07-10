local util = require("util")
local lume = require("lib.lume")
local bitser = require("lib.bitser")
local ui = require("ui")

local Object = require("lib.classic")
local Editor = Object:extend()

local tiles = {
    {name="blank", color={228,241,254}}, --1
    {name="wall", color={103,128,159}},  --2
    {name="glass", color={25,181,254}},  --3
    {name="door", color={192,52,43}},    --4
    {name="start", color={245,171,53}},  --5
    {name="end", color={38,194,129}},    --6
    {name="object", color={155,89,182}}, --7
    {name="enemy", color={207,0,15}},    --8
    {name="path", color={241,169,160}},  --9
}

local helpToggle = "h - toggle help"
local help = [[
escape - main menu
right mouse - move map
left mouse - draw tile
mouse wheel - change tile
1-9 key - select tile
ctrl+s - save map
ctrl+mwheel - zoom in/out
m - toggle minimap
~ - toggle debug info
]]

local debugInfo = [[
camerax: %d, cameray: %d
tilex: %d, tiley: %d
mousex: %d, mousey: %d
mousetx: %d, mousety: %d
]]

function Editor:new(map, camera)
    self.map = map
    self.camera = camera
    self:reset()
end

function Editor:reset()
    self.tileSize = 32
    self.selectedTileIndex = 1
    self.font = love.graphics.newFont("fonts/OpenSans-Light.ttf", 13)
    self.visibility = {}
    self.visibility.prompt = false
    self.visibility.minimap = true
    self.visibility.debug = false
    self.visibility.help = false
    self.camera:setBounds()
    self.mouseLeftPressed = false
    self.mouseRightPressed = false
    self.toolbar = self:createToolbar()
end

function Editor:paintTile(index, x, y)
    local mapItems = self.map.items
    if mapItems[x] == nil then
        mapItems[x] = {}
    end

    mapItems[x][y] = index
end

function Editor:createToolbar()
    return ui.column {
        x=10,y=10,
        spacing=10,
        ui.repeater {
            times=#tiles,
            ui.button {
                width=75,
                height=50,
                tile=function(t) return tiles[t.index] end,
                selected=function(t) return t.index == self.selectedTileIndex end,
                color=function(t) 
                    local color = {t.tile.color[1], t.tile.color[2], t.tile.color[3],t.selected and 255 or 100}
                    return color
                end,
                border={
                    width=1,
                    color=function(t) return t.tile.color end
                },
                text={
                    color=function(t)
                      return t.selected and ui.util.lightness(t.tile.color) > 0.5 and {50,50,50} or {255,255,255}
                    end,
                    value=function(t) return t.tile.name end
                },
                onPressed=function(t) return function() print("asd"); self.selectedTileIndex = t.index end end
            }
        }
    }
end

function Editor:update(dt)
    self.toolbar:update()
end

function Editor:draw(x, y, w, h)
    self:drawCheckerBoard(x,y,w,h)
    self:drawMapBorder()
    self:drawMap()
end

function Editor:drawUi()
    --self:drawToolbar(0,0)
    local lastFont = love.graphics.getFont()
    love.graphics.setFont(self.font)
    if self.visibility.debug then
        self:drawDebugInfo()
    end
    self:drawHelp()

    self.toolbar:draw()

    if self.visibility.minimap then
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local width, height = 200, 200
        local x, y = screenWidth - width, screenHeight - height
        self:drawMinimap(x, y, width, height, 10)
    end
    love.graphics.setFont(lastFont)
end

function Editor:drawToolbar(x, y)
    local margin = 10
    local padding = 10
    local width = 100
    local screenHeight = love.graphics.getHeight()
    local height = #tiles * width - (#tiles-1) * (margin+padding)
    local maxY = y + self.selectedTileIndex * width - (self.selectedTileIndex-1)*(margin+padding)

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
            self:drawTileIcon(margin, padding, width, width, index, tile.name, tile.color, index == self.selectedTileIndex)
            love.graphics.translate(0, width-margin-padding)
        end
        love.graphics.pop()

        love.graphics.pop() 
    end
end

function Editor:drawCheckerBoard(x, y, w, h)
    local beginX = math.floor(x / self.tileSize) * self.tileSize
    local beginY = math.floor(y / self.tileSize) * self.tileSize
    local horizontalCount = math.ceil(w / self.tileSize) + 1
    local verticalCount = math.ceil(h / self.tileSize) + 1
    local xEven = math.floor(x / self.tileSize) % 2 == 0
    local yEven = math.floor(y / self.tileSize) % 2 == 0
    local evenOffset = (xEven and 1 or 0) + (yEven and 1 or 0)

    love.graphics.push()
    love.graphics.translate(beginX, beginY)
    for i=1, horizontalCount do
        for j=1, verticalCount do
            local x = (i-1)*self.tileSize
            local y = (j-1)*self.tileSize
            local isEven = ((i + j + evenOffset) % 2 == 0)
            local color = isEven and {52,52,52} or {65,65,65}
            love.graphics.setColor(color)
            love.graphics.rectangle("fill", x, y, self.tileSize, self.tileSize)
        end
    end
    love.graphics.pop()
end

function Editor:drawMap()
    for x, row in pairs(self.map.items) do
        for y, index in pairs(row) do
            local tile = tiles[index]
            love.graphics.setColor(tile.color)
            love.graphics.rectangle("fill", x*self.tileSize, y*self.tileSize, self.tileSize, self.tileSize)
        end
    end
end

function Editor:drawMapBorder()
    local map = self.map
    local x,y = map.x * self.tileSize, map.y*self.tileSize
    local w,h = map.width*self.tileSize, map.height*self.tileSize
    love.graphics.setColor(255,255,255,20)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(255,255,255,50)
    love.graphics.rectangle("line", x, y, w, h)
end

function Editor:drawMinimap(x, y, w, h, scale)
    local scale = scale * self.camera.scale
    love.graphics.setScissor(x, y, w, h)
    love.graphics.setColor(0,0,0,50)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(0,0,0,100)
    love.graphics.rectangle("line", x, y, w, h)

    local cameraWidth = self.camera.scaledWidth / scale
    local cameraHeight = self.camera.scaledHeight / scale
    local cameraX = (x+w/2)-cameraWidth/2
    local cameraY = (y+h/2)-cameraHeight/2

    love.graphics.push()
    love.graphics.translate(cameraX, cameraY)
    love.graphics.scale(1 / scale, 1 / scale)
    love.graphics.translate(-self.camera.x, -self.camera.y)

    self:drawMap()

    love.graphics.pop()

    love.graphics.setColor(255,255,255)
    love.graphics.rectangle("line", cameraX, cameraY, cameraWidth, cameraHeight)

    love.graphics.setScissor()
end

function Editor:drawHelp()
    local width, height = love.graphics.getDimensions()
    love.graphics.setColor(255,255,255)
    love.graphics.print(helpToggle, width - self.font:getWidth(helpToggle), 0)
    if self.visibility.help then
        love.graphics.printf(help, 0, self.font:getHeight(), width, "right")
    end
end

function Editor:drawFilePrompt()
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
        love.graphics.print(self.mapname, 5, (height - self.font:getHeight()) / 2)
        love.graphics.pop()
    end
end

function Editor:drawTileIcon(margin, padding, width, height, index, text, rgba, selected)
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

        love.graphics.print(index, width/2-self.font:getWidth(index)/2,width/2-self.font:getHeight()/2)

        love.graphics.pop()
    end

    love.graphics.pop() 
end

function Editor:drawDebugInfo()
    love.graphics.setColor(255,255,255)

    local screenHeight = love.graphics.getHeight()

    local text = string.format(debugInfo, 
        self.camera.x, self.camera.y, 
        math.floor(self.camera.x/self.tileSize), math.floor(self.camera.y/self.tileSize),
        self.camera:getMouseX(), self.camera:getMouseY(),
        math.floor(self.camera:getMouseX() / self.tileSize), math.floor(self.camera:getMouseY() / self.tileSize))

    local width, wrappedtext = self.font:getWrap(text, 200)
    local lineHeight = self.font:getLineHeight()
    local increment = lineHeight * self.font:getHeight()

    local y = screenHeight - (#wrappedtext * increment)

    for i=1, #wrappedtext do
        love.graphics.print(wrappedtext[i], 0, y)
        y = y + increment
    end

    --love.graphics.printf(text, 0, y, width)

    
end

function Editor:getSelectedPosition(items, comparer)
    local selectedX, selectedY = 0, 0

    for x, row in pairs(self.map.items) do
        if comparer(selectedX, x) then
            selectedX = x
        end

        for y, index in pairs(row) do
            if comparer(selectedY, y) then
                selectedY = y
            end
        end
    end

    return selectedX, selectedY
end

function Editor:getSmallestPosition(items)
    return self:getSelectedPosition(items, function(selected, current) return current < selected end)
end

function Editor:getLargestPosition(items)
    return self:getSelectedPosition(items, function(selected, current) return current > selected end)
end

function Editor:normalizeMap()
    local items, len = self.world:getItems()
    local x, y = self:getSmallestPosition(items)
    local offsetX, offsetY = 0-x,0-y

    for i=1, len do
        local item = items[i]
        item.x = item.x + offsetX
        item.y = item.y + offsetY
        self.world:update(item, item.x + offsetX, item.y + offsetY)
    end

    return items, len
end

function Editor:toMapCoordinates(worldX, worldY)
    return math.floor(worldX / self.tileSize), math.floor(worldY / self.tileSize)
end

function Editor:load(filename)
    local level = bitser.loadLoveFile("maps/" .. filename)
    return level
end

function Editor:save(filename)
    local file, errorstr = love.filesystem.newFile("maps/" .. filename, "w")
    if file then
        print("saving file")
        local items, len = self.world:getItems()

        local mapX, mapY = self:getSmallestPosition(items)
        local maxMapX, maxMapY = self:getLargestPosition(items)
        local mapWidth = maxMapX - mapX
        local mapHeight = maxMapY - mapY

        mapX = mapX / self.tileSize
        mapY = mapY / self.tileSize
        mapWidth = mapWidth / self.tileSize + 1
        mapHeight = mapHeight / self.tileSize + 1

        local mappedItems = {}

        for i=1, len do
            local item = items[i]
            table.insert(mappedItems, {x=item.x/self.tileSize,y=item.y/self.tileSize,tile=item.index})
        end

        print("w", mapWidth)
        print("h", mapHeight)

        local map = {}
        map.version = 1
        map.items = mappedItems
        map.x = mapX
        map.y = mapY
        map.width = mapWidth
        map.height = mapHeight
        self.map = map

        local encoded = luatable.encode_pretty(map)
        file:write(encoded)
        file:close()
    else
        error(errorstr)
    end
end

function Editor:mousePressed(x, y, button)
    if self.toolbar:mousePressed(x, y, button) then
        return true
    end


    if button == 1 then
        self.mouseLeftPressed = true
        local worldX, worldY = self.camera:toWorld(x, y)
        local tileX, tileY = self:toMapCoordinates(worldX, worldY)
        local index = self.selectedTileIndex 
        self:paintTile(index ~= 1 and index or nil, tileX, tileY)
    elseif button == 2 then
        self.mouseRightPressed = true
    end
end

function Editor:mouseReleased(x, y, button)
    if self.toolbar:mouseReleased(x, y, button) then
        return true
    end

    if button == 1 then
        self.mouseLeftPressed = false
    elseif button == 2 then
        self.mouseRightPressed = false
    end
end

function Editor:wheelMoved(x, y)
    if love.keyboard.isDown("lctrl") then
        self.camera.scale = lume.clamp(self.camera.scale - y, 1, 5)
    else
        self.selectedTileIndex = lume.clamp(self.selectedTileIndex - y, 1, #tiles)
    end
end

function Editor:mouseMoved(x, y, dx, dy, istouch)
    if self.toolbar:mouseMoved(x, y, dx, dy, istouch) then
        return true
    end

    if self.mouseLeftPressed then
        local worldX, worldY = self.camera:toWorld(x, y)
        local tileX, tileY = self:toMapCoordinates(worldX, worldY)
        local index = self.selectedTileIndex 
        self:paintTile(index ~= 1 and index or nil, tileX, tileY)
    elseif self.mouseRightPressed then
        self.camera:move(-dx, -dy)
    end
end

function Editor:keyPressed(key, scancode)
    local num = tonumber(scancode)

    if self.visibility.prompt then
        if scancode == "backspace" then
            self.mapname = self.mapname:sub(1, -2)
        elseif scancode == "return" then
            self:loadMapFile()
        elseif #scancode == 1 and #self.mapname < 20 then
            if string.match(scancode, "[0-9]") or string.match(scancode, "[a-z]") then
                self.mapname = self.mapname .. scancode
            end
        end
        
        return
    end

    if love.keyboard.isDown("lctrl") and key == "s" then
        self:save(self.mapname)
    end

    if num and num >= 1 and num <= #tiles then
        self.selectedTileIndex = num
    end

    if key == "m" then
        self.visibility.minimap = not self.visibility.minimap
    end

    if scancode == "`" then
        self.visibility.debug = not self.visibility.debug
    end

    if key == "h" then
        self.visibility.help = not self.visibility.help
    end
end

function Editor:keyReleased(key, scancode)
end

return Editor