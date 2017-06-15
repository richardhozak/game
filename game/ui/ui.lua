local Button = require("ui.button")

local Object = require("lib.classic")
local Ui = Object:extend()

local util = require("util")

local function bind(target, property)
    return function() return target[property] end
end

function recursiveEnumerate(folder, fileTree)
    local lfs = love.filesystem
    local filesTable = lfs.getDirectoryItems(folder)
    for i,v in ipairs(filesTable) do
        local file = folder.."/"..v
        if lfs.isFile(file) then
            fileTree = fileTree.."\n"..file
        elseif lfs.isDirectory(file) then
            fileTree = fileTree.."\n"..file.." (DIR)"
            fileTree = recursiveEnumerate(file, fileTree)
        end
    end
    return fileTree
end

local function testOne(text)
    print(text)
    return function (textTwo) print(textTwo) end
end

function Ui:new()
    self.pauseMenu = {}
    self.mainMenu = {}
    self.levelMenu = {}
    self.currentMenu = nil

    self.displayMenu = true
    self.isPaused = false
    self.loadLevel = false

    self.selectedLevel = nil

    self.loadLevelCallback = nil

    local item = nil

    -- pausemenu
    item = Button(self, 0,0,100,50, {
            color={246,36,89}, 
            text="Resume",
            onClicked=function() self.displayMenu = false end
        }
    )

    table.insert(self.pauseMenu, item)

    item = Button(self, 0,100,100,50, {
            color={246,36,89}, 
            text="Load",
            onClicked=function() self:displayLevelMenu() end
        }
    )

    table.insert(self.pauseMenu, item)

    item = Button(self, 0,200,100,50, {
            color={246,36,89}, 
            text="Exit",
            onClicked=love.event.quit
        }
    )

    table.insert(self.pauseMenu, item)

    -- mainmenu
    item = Button(self, 0,0,100,50, {
            color={246,36,89}, 
            text="Load",
            onClicked=function() return self:displayLevelMenu() end
        }
    )

    table.insert(self.mainMenu, item)

    item = Button(self, 0,60,100,50, {
            color={246,36,89}, 
            text="Exit",
            onClicked=love.event.quit
        }
    )

    table.insert(self.mainMenu, item)
end

function Ui:setLoadLevelCallback(callback)
    self.loadLevelCallback = callback
end

function Ui:displayLevelMenu()
    print("loading levels")
    self.levelMenu = {}
    local dir = "/maps"
    local files = love.filesystem.getDirectoryItems(dir)
    local i=0
    for k,v in ipairs(files) do
        if (love.filesystem.isFile(dir .. "/" .. v)) then
            local item = Button(self, 0, i*60, 100, 50, {
                color={25,181,254}, 
                text=v,
                onClicked=function() 
                    self:loadLevelFile(v)
                end
                })
            i = i+1
            table.insert(self.levelMenu, item)
        end
    end

    local item = Button(self, 0, i*60, 100, 50, {
                color={246,36,89}, 
                text="Back",
                onClicked=function() 
                    self.loadLevel = false
                end
                })

    table.insert(self.levelMenu, item)
    self.loadLevel = true
end

function Ui:loadLevelFile(file)
    if self.loadLevelCallback then
        self.loadLevelCallback(file)
    end
end

function Ui:update(dt)
    if self.displayMenu then
        if self.isPaused then
            self.currentMenu = self.pauseMenu
        elseif self.loadLevel then
            self.currentMenu = self.levelMenu
        else
            self.currentMenu = self.mainMenu
        end
    end

    if self.currentMenu then
        for i,item in ipairs(self.currentMenu) do
            item:update(dt)
        end
    end

    --[[
    if love.mouse.isVisible() and not self.isPaused then
        love.mouse.setVisible(false)
    end
    --]]
end

function Ui:getMousePosition()
    return love.mouse.getPosition()
end

function Ui:isMouseDown()
    return love.mouse.isDown(1)
end

function Ui:draw(x, y, width, height)
    if self.currentMenu then
        for i,item in ipairs(self.currentMenu) do
            item:draw()
        end
    end
end

function Ui.onPaused()
    if self.paused then
    else
    end
end

function Ui:getPaused()
    return self.paused
end

function Ui:setPaused(paused)
    if self.paused ~= paused then
        self.paused = paused
        self.onPaused()
    end
end

return Ui()