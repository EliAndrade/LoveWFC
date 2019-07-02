
local image = love.graphics.newImage("Image2.png")
local quads = {
	["E"] = love.graphics.newQuad( 0, 0, 16, 16, 80, 32),
	["V"] = love.graphics.newQuad(16, 0, 16, 16, 80, 32),
	["H"] = love.graphics.newQuad( 0,16, 16, 16, 80, 32),
	["X"] = love.graphics.newQuad(16,16, 16, 16, 80, 32),
	["UL"] = love.graphics.newQuad(32, 0, 16, 16, 80, 32),
	["UR"] = love.graphics.newQuad(48, 0, 16, 16, 80, 32),
	["DL"] = love.graphics.newQuad(32,16, 16, 16, 80, 32),
	["DR"] = love.graphics.newQuad(48,16, 16, 16, 80, 32),
	["C"] =  love.graphics.newQuad(64, 0, 16, 16, 80, 32),
}

local TILE_SIZE = 16
love.graphics.setBackgroundColor(0.7, 0.7, 0)
function love.draw()
	

	for y = 1, h do
		for x = 1, w do
			for i, v in ipairs(wave.map[y][x]) do	
				love.graphics.setColor(1, 1, 1, 1-wave:getEntropy(x, y))
				love.graphics.draw(image, quads[v.name], (x-1)*TILE_SIZE, (y-1)*TILE_SIZE)
			end
		end
	end
	
	for i, v in ipairs(wave.stack) do
		love.graphics.setColor(1, 0, 0, 1)
	
		love.graphics.rectangle("line", (v[1]-1)*TILE_SIZE, (v[2]-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
	end
	
	love.graphics.print(love.timer.getFPS())
	
	weightmenu:draw()
end
