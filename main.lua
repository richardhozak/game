Timer = require("hump.timer")
Input = require("Input")

function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        if love.filesystem.isFile(file) then
            table.insert(file_list, file)
        elseif love.filesystem.isDirectory(file) then
            recursiveEnumerate(file, file_list)
        end
    end
end

function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        print(file)
        require(file)
    end
end

local seen={}

function dump(t,i)
	seen[t]=true
	local s={}
	local n=0
	for k in pairs(t) do
		n=n+1 s[n]=k
	end
	table.sort(s)
	for k,v in ipairs(s) do
		print(i,v)
		v=t[v]
		if type(v)=="table" and not seen[v] then
			dump(v,i.."\t")
		end
	end
end

function requireDir(dirname)
	local class_files = {}
    recursiveEnumerate(dirname, class_files)
    requireFiles(class_files)
end

function love.load()
    requireDir("classes")
    input = Input()
    input:bind("left", "left")
    input:bind("right", "right")
    input:bind("up", "up")
    input:bind("down", "down")
    input:bind("a", "left")
    input:bind("d", "right")
    input:bind("w", "up")
    input:bind("s", "down")
    input:bind("mouse1", "shoot")
    input:bind("space", "shoot")
    timer = Timer()
    rekt = Rectangle()
    player = Player(0,0)
end

function love.update(dt)
	timer:update(dt)
	--rekt:update(dt)
	player:update(dt)
end

function love.draw()
	--rekt:draw()
	player:draw()
end
