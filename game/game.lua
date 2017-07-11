local Camera = require("camera")
local Level = require("level")
local Editor = require("editor")
local bitser = require("lib.bitser")
local ui = require("ui")

local Object = require("lib.classic")
local Game = Object:extend()

local debugInfo = [[
x: %f
y: %f
w: %f
h: %f
]]

function Game:new()
    self.camera = Camera()
    self.tileSize = 32

    self.editor = Editor(self.camera)
    self.level = Level(self.camera)

    self.system = self.level

    self.uiVisible = true
    self.ui = self:createUi()
end

function Game:createUi()
    return ui.column {
        x=10, --function(item) return (love.graphics.getWidth() - item.width) / 2 end
        y=10,
        ui.button {
            text={
                color={50,50,50},
                value=function() return self.system == self.editor and "editor" or self.system == self.level and "level" or "none" end,
            },
            onPressed=function(item) 
                return function()
                    print("setting system")
                    if not self.system then
                        self.system = self.editor
                    elseif self.system == self.level then
                        self.system = self.editor
                    else
                        self.system = self.level
                    end
                end
            end
        },
        ui.input {
            visible=function(item)
                return self.system == self.editor
            end,
            onAccepted=function(item)
                return function(value)
                    self.editor:load(value)
                    self.uiVisible = false
                end
            end
        },
        ui.repeater {
            levels=function(item) return love.filesystem.getDirectoryItems("maps") end,
            times=function(item) return item.levels and #item.levels or 0 end,
            ui.button {
                text={
                    value=function(item) return item.parent.levels[item.index] end,
                    color={50,50,50}
                },
                onClicked=function(item)
                    return function()
                        print("loading", item.text.value)
                        self.system:load(item.text.value)
                        self.uiVisible = false
                    end
                end
            }
        }
    }
end

function Game:update(dt)
    if self.system and self.system.map then
        self.system:update(dt)
    end

    self.camera:update(dt)
    if self.uiVisible then
        self.ui:update()
    end
end

function Game:draw()
    self.camera:draw(function(x, y, w, h)
        if self.system and self.system.map then
            self.system:draw(x, y, w, h)
        end
    end)

    if self.system and self.system.map and self.system.drawUi then
        self.system:drawUi()
    end

    if self.uiVisible then
        self.ui:draw()
    end
end

function Game:drawDebugInfo()
    love.graphics.setColor(255,255,255)
    love.graphics.print(string.format(debugInfo, self.camera.x, self.camera.y, self.camera.width, self.camera.height))
end

function Game:keyPressed(key, scancode, isrepeat)
    if key == "escape" then
        self.uiVisible = not self.uiVisible
    end

    if self.uiVisible and self.ui:keyPressed(key, scancode, isrepeat) then
        return
    end

    if key == "s" and love.keyboard.isDown("lctrl") then
        self.system:save()
        return
    end


    if self.system and self.system.map then
        self.system:keyPressed(key, scancode, isrepeate)
    end
end

function Game:keyReleased(key, scancode)
    if self.uiVisible and self.ui:keyReleased(key, scancode) then
        return 
    end

    if self.system and self.system.map then
        self.system:keyReleased(key, scancode)
    end
end

function Game:mousePressed(x, y, button, istouch)
    if self.uiVisible and self.ui:mousePressed(x, y, button, istouch) then
        return
    end

    if self.system and self.system.map then
        self.system:mousePressed(x, y, button, istouch)
    end
end

function Game:mouseReleased(x, y, button, istouch)
    if self.uiVisible and self.ui:mouseReleased(x, y, button, istouch) then
        return
    end

    if self.system and self.system.map then
        self.system:mouseReleased(x, y, button, istouch)
    end
end

function Game:mouseMoved(x, y, dx, dy, istouch)
    if self.uiVisible and self.ui:mouseMoved(x, y, dx, dy, istouch) then
        return
    end

    if self.system and self.system.map then
        self.system:mouseMoved(x, y, dx, dy, istouch)
    end
end

function Game:textInput(text)
    if self.uiVisible and self.ui:textInput(text) then
        return
    end
end

function Game:wheelMoved(x, y)
    if self.system and self.system.map then
        self.system:wheelMoved(x, y)
    end
end

return Game