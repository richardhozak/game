local util = require("util")
local bump = require("lib.bump")
local luatable = require("lib.LuaTable")
local bump_debug = require("lib.bump_debug")
local nk = require("nuklear")

local Object = require("lib.classic")
local Editor = Object:extend()

local tiles = {
    {name="blank", color={228,241,254}},
    {name="wall", color={103,128,159}},
    {name="glass", color={25,181,254}},
    {name="door", color={192,52,43}},
    {name="start", color={245,171,53}},
    {name="end", color={38,194,129}},
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

function Editor:new(camera)
    self.camera = camera
    print("camera", type(self.camera), self.camera)
    self:reset()    
end

function Editor:reset()
    self.visibility = {}
    self.visibility.prompt = true
    self.visibility.minimap = true
    self.visibility.help = false
    self.visibility.debug = false
    
    self.selectedTileIndex = 1
    self.width, self.height = love.graphics.getDimensions()
    self.saveDir = love.filesystem.getSaveDirectory()
    self.font = love.graphics.newFont(12)
    
    self.axis = {}
    self.axis.locked = false
    self.axis.direction = nil
    self.axis.column = nil
    self.axis.row = nil

    self.tileSize = 32
    self.beginX, self.beginY = 0
    self.cameraX, self.cameraY = 0
    self.mapname = ""
    self.world = nil
    self.map = nil

    self.mouse = {}
    self.mouse.x = 0
    self.mouse.y = 0
    self.mouse.left = false
    self.mouse.right = false

    self.mapNameTable = {}
    self.mapNameTable.value = ""
end

function Editor:update(dt)
    self.mouse.x, self.mouse.y = love.mouse.getPosition()

    if self.visibility.prompt or not self.world then
        return true
    end

    if self.mouse.right then
        local diffX = (self.mouse.x - self.beginX) * self.camera.scaleX
        local diffY = (self.mouse.y - self.beginY) * self.camera.scaleX
        self.camera:setPosition(self.cameraX - diffX, self.cameraY - diffY)
    end

    if self.mouse.left then
        local mouseX, mouseY = self.camera:getMousePosition()
        local column = math.floor(mouseX / self.tileSize)
        local row = math.floor(mouseY / self.tileSize)
        local allowDraw = true

        if love.keyboard.isDown("lshift") then
            if not self.axis.column and not self.axis.row then
                print("setting position", self.axis.column, self.axis.row)
                self.axis.column, self.axis.row = column, row
                self.axis.direction = nil
            elseif not axisDirection then
                local horizontalDiff = math.abs(self.axis.column - column) > 0
                local verticalDiff = math.abs(self.axis.row - row) > 0

                if horizontalDiff and verticalDiff then
                    -- diagonal dragging not supported
                    allowDraw = false
                elseif horizontalDiff then
                    self.axis.direction = "horizontal"
                elseif verticalDiff then
                    self.axis.direction = "vertical"
                else
                    print("no movement")
                end

                print("setting axis direction", self.axis.direction)
            else
                local horizontalDiff = math.abs(self.axis.column - column) > 0
                local verticalDiff = math.abs(self.axis.row - row) > 0
                
                if axisDirection == "horizontal" then
                    if verticalDiff then
                        row = self.axis.row
                    end
                elseif axisDirection == "vertical" then
                    if horizontalDiff then
                        column = self.axis.column
                    end
                else
                    print("invalid axis direction", self.axis.direction)
                    allowDraw = false
                end
            end
        end

        if allowDraw then
            local items, len = self.world:queryRect(column * self.tileSize, row * self.tileSize, self.tileSize, self.tileSize)
            local tile = tiles[self.selectedTileIndex]
            for i=1, len do
                self.world:remove(items[i])
            end

            if tile.name ~= "blank" then
                local item = {x=column * self.tileSize, y=row * self.tileSize, index=self.selectedTileIndex}
                self.world:add(item, item.x, item.y, self.tileSize, self.tileSize)
            end
        end
    end

    return true
end

function Editor:draw(x, y, w, h)
    self:drawCheckerBoard(x,y,w,h)
    if self.world then
        self:drawMapBorder()
        self:drawMap()
    end
    if self.visibility.debug then
        bump_debug.draw(self.world, x, y, w, h)
    end
end

function Editor:drawUi()
    if self.visibility.prompt then
        self:drawFilePrompt()
        return
    end

    self:drawToolbar(0,0)

    local width, height = love.graphics.getDimensions()

    love.graphics.setColor(255,255,255,255)
    love.graphics.print("location: " .. self.saveDir, 0, height - self.font:getHeight())

    love.graphics.print(helpToggle, width - self.font:getWidth(helpToggle), 0)
    if self.visibility.help then
        love.graphics.printf(help, width - 200, self.font:getHeight(),200,"right")
    end

    if not self.visibility.prompt then
        local mapDisplay = "map: " .. self.mapname
        love.graphics.print(mapDisplay, width - self.font:getWidth(mapDisplay), height - self.font:getHeight())
    end

    if self.visibility.minimap then
        local minimapWidth = width / 4
        local minimapHeight = minimapWidth * 0.75
        self:drawMinimap(width-minimapWidth,height-minimapHeight-25, minimapWidth, minimapHeight, 10*self.camera.scaleX, self.camera)
    end

    if self.visibility.debug then
        self:drawDebugInfo()
    end
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
    love.graphics.setColor(255,255,255,255)
    local items, len = self.world:getItems()
    for i=1, len do
        local item = items[i]
        local tile = tiles[item.index]
        love.graphics.setColor(tile.color)
        love.graphics.rectangle("fill", item.x, item.y, self.tileSize, self.tileSize)
    end
end

function Editor:drawMapBorder()
    if not self.map then
        return
    end

    local map = self.map
    local x,y = map.x * self.tileSize, map.y*self.tileSize
    local w,h = map.width*self.tileSize, map.height*self.tileSize
    love.graphics.setColor(255,255,255,20)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(255,255,255,50)
    love.graphics.rectangle("line", x, y, w, h)
end

function Editor:drawMinimap(x, y, w, h, scale, camera)
    local scale = scale > 0 and scale or 1
    love.graphics.setScissor(x, y, w, h)
    love.graphics.setColor(0,0,0,50)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(0,0,0,100)
    love.graphics.rectangle("line", x, y, w, h)

    local cameraWidth = camera.width / scale
    local cameraHeight = camera.height / scale
    local cameraX = (x+w/2)-cameraWidth/2
    local cameraY = (y+h/2)-cameraHeight/2

    love.graphics.push()
    love.graphics.translate(cameraX, cameraY)
    love.graphics.scale(1 / scale, 1 / scale)
    love.graphics.translate(-camera.x, -camera.y)

    self:drawMap()

    love.graphics.pop()

    love.graphics.setColor(255,255,255)
    love.graphics.rectangle("line", cameraX, cameraY, cameraWidth, cameraHeight)

    love.graphics.setScissor()
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

    love.graphics.print(string.format(debugInfo, self.camera.x, self.camera.y, 
        math.floor(self.camera.x/self.tileSize), math.floor(self.camera.y/self.tileSize),
        self.camera:getMouseX(), self.camera:getMouseY(),
        math.floor(self.camera:getMouseX() / self.tileSize), math.floor(self.camera:getMouseY() / self.tileSize)))
end

function Editor:updateUi()
    local screenWidth, screenHeight = love.graphics.getDimensions()

    if self.visibility.prompt then
        local width = 300
        local height = 80
        local x = (screenWidth-width)/2
        local y = (screenHeight-height)/2
        if nk.windowBegin("Map name", x, y, width, height, "title", "movable", "border") then
            nk.layoutRow("dynamic", 35, {0.75,0.25})
            local state, changed = nk.edit("field", self.mapNameTable)
            if nk.button("Enter") or (state == "active" and love.keyboard.isDown("return")) then
                self:loadMapFile(self.mapNameTable.value)
            end
        end
        nk.windowEnd()
        return
    end


    if nk.windowBegin("Tiles", 0, 0, 100, screenHeight-25) then
        nk.layoutRow("dynamic", 35, 1)
        for index, tile in ipairs(tiles) do
            if nk.groupBegin(tile.name) then
                nk.label(tile.name)
                if nk.button(nil, nk.colorRGBA(unpack(tile.color))) then
                    self.selectedTileIndex = index
                end
                nk.groupEnd()
            end
        end
    end
    nk.windowEnd()


    if nk.windowBegin("Mapname", 0, screenHeight - 25, screenWidth, 25) then
        nk.layoutRow("dynamic", 25, 1)
        nk.label(self.saveDir)
        nk.label(self.mapname, "right")
    end
    nk.windowEnd()
end

function Editor:getSelectedPosition(items, comparer)
    local item = items[1]
    local selectedX, selectedY = 0, 0

    if item then
        selectedX, selectedY = item.x, item.y
    end

    for i=2, #items do
        item = items[i]

        if comparer(selectedX, item.x) then
            selectedX = item.x
        end

        if comparer(selectedY, item.y) then
            selectedY = item.y
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

function Editor:loadMap(filename)
    local world = bump.newWorld(self.tileSize)

    filename = "maps/" .. filename
    
    if not love.filesystem.exists(filename) then
        return world, {
            x=0,
            y=0,
            width=0,
            height=0,
            items={}
        }
    end

    local map = love.filesystem.load(filename)()

    for index, item in ipairs(map.items) do
        item.index = item.tile
        item.tile = nil
        item.x = item.x * self.tileSize
        item.y = item.y * self.tileSize
        world:add(item, item.x, item.y, self.tileSize, self.tileSize)
    end

    return world, map
end

function Editor:saveMap(filename)
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
    if button == 1 then
        self.mouse.left = true
    end

    if button == 2 then
        self.mouse.right = true
    end

    if button == 2 or button == 1 then
        self.cameraX = self.camera.posX
        self.cameraY = self.camera.posY
        self.beginX, self.beginY = x, y
        print("dragstart", x,y,button)
    end
end

function Editor:mouseReleased(x, y, button)
    if button == 1 then
        self.mouse.left = false
    end

    if button == 2 then
        self.mouse.right = false
    end

    if button == 2 or button == 1 then
        self.beginX, self.beginY = nil, nil
        self.axis.column, self.axis.row = nil, nil
        self.axis.direction = nil
        print("dragended",x,y,button)
    end
end

function Editor:wheelMoved(x, y)
    if self.visibility.prompt then
        return
    end

    if love.keyboard.isDown("lctrl") then
        if y > 0 then
            self.camera:setScale(self.camera.scaleX - 1, self.camera.scaleY - 1)
        elseif y < 0 then
            self.camera:setScale(self.camera.scaleX + 1, self.camera.scaleY + 1)
        end
    else
        if y > 0 then
            local newIndex = self.selectedTileIndex - 1
            if newIndex >= 1 then
                self.selectedTileIndex = newIndex
            end
        elseif y < 0 then
            local newIndex = self.selectedTileIndex + 1
            if newIndex <= #tiles then
                self.selectedTileIndex = newIndex
            end
        end
    end
end

function Editor:loadMapFile(filename)
    if #filename > 0 then
        filename = filename .. ".lua"
        self.world, self.map = self:loadMap(filename)
        self.camera:setPosition(self.map.x*self.tileSize, self.map.y*self.tileSize)
        self.visibility.prompt = false
        self.mapname = filename
    end
end

function Editor:keyPressed(key, scancode)
    local num = tonumber(scancode)
    print("pressed ", key, scancode, num)

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

    if love.keyboard.isDown("lctrl") then
        if key == "s" then
            self:saveMap(self.mapname)
        elseif key == "n" then
            print("normalizing map")
            local items, len = self:normalizeMap()
            self.world = bump.newWorld(self.tileSize)
            for i=1,len do
                local item = items[i]
                self.world:add(item, item.x, item.y, self.tileSize, self.tileSize)
            end
        end
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
    print("released", key, scancode)
end

return Editor