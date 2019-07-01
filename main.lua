local Tile = require "Tile"
local WaveTile = require "WaveTile"

local dirs = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}
local dirsnames = {"up", "down", "left", "right"}

local Menu = require "Menu"


local tiles = {
	Tile:new("H", 0, {}, {}, {}, {}),
	Tile:new("V", 0, {}, {}, {}, {}),
	Tile:new("X", 0, {}, {}, {}, {}),
	Tile:new("E", 0, {}, {}, {}, {}),
	
	Tile:new("DR", 0, {}, {}, {}, {}),
	Tile:new("DL", 0, {}, {}, {}, {}),
	Tile:new("UR", 0, {}, {}, {}, {}),
	Tile:new("UL", 0, {}, {}, {}, {}),

	Tile:new("C", 0, {}, {}, {}, {}),
}

local lookup = {
	H = tiles[1],
	V = tiles[2],
	X = tiles[3],
	E = tiles[4],
	DR = tiles[5],
	DL = tiles[6],
	UR = tiles[7],
	UL = tiles[8],
	C = tiles[9]
} 

local input = {
    {'E', 'E' , 'E', 'E' ,'E' , 'E' , 'E', 'E' },
    {'E', 'DR', 'H', 'DL','E' , 'C' , 'C', 'E' },
    {'E', 'V' , 'E', 'V' ,'E' , 'E' , 'E', 'E' },
    {'E', 'V' , 'E', 'V' ,'E' , 'E' , 'E', 'E' },
    {'E', 'UR', 'H', 'X' ,'H' , 'H' ,'DL', 'E' },
    {'E', 'E' , 'E', 'V' ,'E' , 'E' , 'V', 'E' },
    {'E', 'C' , 'E', 'UR','H' , 'H' ,'UL', 'E' },
    {'E', 'C' , 'E', 'E' ,'E' , 'E' , 'E', 'E' },
    {'E', 'E' , 'E', 'E' ,'E' , 'E' , 'E', 'E' },
}


lookup.X.weight = 10

for y = 1, #input do
	for x = 1, #input[y] do
		lookup[input[y][x]].weight = lookup[input[y][x]].weight + 1
		for i = 1, #dirs do
			if  dirs[i][1] + x >= 1 and dirs[i][1] + x <= #input[y]
			and dirs[i][2] + y >= 1 and dirs[i][2] + y <= #input then
				
				local this = lookup[input[y][x]]
				local other = lookup[input[dirs[i][2] + y][dirs[i][1] + x]]
				local found = false
				
				for j, k in ipairs(this.rules[dirsnames[i]]) do
					if k == other.name then
						found = true
						break
					end
				end
				
				if not found then
					table.insert(this.rules[dirsnames[i]], other.name)
				end
			end
		end
	end
end


--/Menu
local t = {}
local function less(self)
	self.tile.weight = self.tile.weight > 0 and self.tile.weight - 1 or 0
	self.text = ("%s: %i"):format(self.tile.name, self.tile.weight)
end
local function more(self)
	self.tile.weight = self.tile.weight + 1
	self.text = ("%s: %i"):format(self.tile.name, self.tile.weight)
end

for i, v in ipairs(tiles) do
	table.insert(t, {
		text = ("%s: %i"):format(v.name, v.weight),
		onLeftPress = less,
		onRightPress = more,
		tile = v
	})
end


local weightmenu = Menu:new(t, 100, #t*16)



--Remove stack from wavetile

local w, h = 20, 20
local wave = WaveTile:start(w, h, tiles)

wave:step(1, 1)

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

function love.update(dt)
	
end

function love.keypressed(key)
	if key == "return" then
		wave = WaveTile:start(w, h, tiles)
		wave:step(math.random(1, w), math.random(1, h))
	elseif key == "a" then
		for i = 1, 10 do
			wave:step()
		end
	elseif key == "b" then
		local it = 0
		while #wave.stack > 0 do
			it = it + 1
			wave:step()
			
			if it > w*h*w then
				break
			end
		end
	end
	
	weightmenu:keypressed(key)
end