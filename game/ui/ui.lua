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
    self.state = "main"

    self.levelMenu = {}
    self.currentMenu = nil

    self.selectedLevel = nil
    self.loadLevelCallback = nil
    self.enterEditorCallback = nil

    self.pauseMenu = {
        Button(self, 100, 50, {
            color={246,36,89}, 
            text="Resume",
            onClicked=function() self.displayMenu = false end
        }),
        Button(self, 100, 50, {
            color={246,36,89}, 
            text="Load",
            onClicked=function() self:displayLevelMenu() end
        }),
        Button(self, 100, 50, {
            color={246,36,89}, 
            text="Main Menu",
            onClicked=function() 
                self.state = "main"
                self:loadLevelFile(nil)
            end
        })
    }

    self.mainMenu = {
        Button(self, 100, 50, {
            color={246,36,89}, 
            text="Editor",
            onClicked=function() return self:enterEditor() end
        }),
        Button(self, 100, 50, {
            color={246,36,89}, 
            text="Load",
            onClicked=function() return self:displayLevelMenu() end
        }),
        Button(self, 100, 50, {
            color={246,36,89}, 
            text="Exit",
            onClicked=love.event.quit
        })
    }
end

function Ui:setEnterEditorCallback(callback)
    self.enterEditorCallback = callback
end

function Ui:setLoadLevelCallback(callback)
    self.loadLevelCallback = callback
end

function Ui:displayLevelMenu()
    print("loading levels")
    self.levelMenu = {}
    local dir = "maps"
    local files = love.filesystem.getDirectoryItems(dir)
    local i=0
    for k,v in ipairs(files) do
        if (love.filesystem.isFile(dir .. "/" .. v)) then
            local item = Button(self, 100, 50, {
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

    local item = Button(self, 100, 50, {
                color={246,36,89}, 
                text="Back",
                onClicked=function() 
                    self.state = "main"
                end
                })

    table.insert(self.levelMenu, item)
    self.state = "load"
end

function Ui:enterEditor()
    if type(self.enterEditorCallback) == "function" then
        self.enterEditorCallback()
    end
end

function Ui:loadLevelFile(file)
    if type(self.loadLevelCallback) == "function" then
        self.loadLevelCallback(file)
    end
end

function Ui:update(dt)
    if self.state == "main" then
        self.currentMenu = self.mainMenu
    elseif self.state == "pause" then
        self.currentMenu = self.pauseMenu
    elseif self.state == "load" then
        self.currentMenu = self.levelMenu
    else
        self.currentMenu = nil
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
    local yOffset = 50
    if self.currentMenu then
        for i,item in ipairs(self.currentMenu) do
            local y = yOffset + (i-1)*70
            item.y = y
            item.x = (x+width-item.width)/2
            item:draw()
        end
    end
end

function Ui:canPause()
end

function Ui:pauseResume()
    if self.state == "none" then
        self.state = "pause"
    elseif self.state == "pause" then
        self.state = "none"
    end
end

function Ui:getPaused()
    return self.state == "pause"
end

return Ui()