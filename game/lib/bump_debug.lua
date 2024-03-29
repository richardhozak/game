local bump_debug = {}

local function getCellRect(world, cx,cy)
  local cellSize = world.cellSize
  local l,t = world:toWorld(cx,cy)
  return l,t,cellSize,cellSize
end

function bump_debug.draw(world)
  local font = love.graphics.getFont()
  for cy, row in pairs(world.rows) do
    for cx, cell in pairs(row) do
      local l,t,w,h = getCellRect(world, cx,cy)
      local intensity = cell.itemCount * 16 + 16
      love.graphics.setColor(255,255,255,intensity)
      love.graphics.rectangle('fill', l,t,w,h)
      love.graphics.setColor(255,255,255,10)
      love.graphics.rectangle('line', l,t,w,h)
      love.graphics.setColor(255,255,255)
      love.graphics.print(cell.itemCount, l+(w-font:getWidth(cell.itemCount))/2, t+(h-font:getHeight())/2)
    end
  end
end

return bump_debug
