local util = {}

util.drawFilledRectangle = function(l,t,w,h, r,g,b)
  love.graphics.setColor(r,g,b,100)
  love.graphics.rectangle('fill', l,t,w,h)
  love.graphics.setColor(r,g,b)
  love.graphics.rectangle('line', l,t,w,h)
end

util.drawFilledCircle = function(x, y, radius, r, g, b)
	love.graphics.setColor(r, g, b, 100)
	love.graphics.circle("fill", x, y, radius)
	love.graphics.setColor(r, g, b, 255)
	love.graphics.circle("line", x, y, radius)
end

return util
