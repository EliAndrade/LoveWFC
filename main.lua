local Tile = require "Tile"
local WaveTile = require "WaveTile"

local dirs = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}
local dirsnames = {"up", "down", "left", "right"}

local tiles = {
	Tile:new("C", 0, {}, {}, {}, {}),
	Tile:new("L", 0, {}, {}, {}, {}),
	Tile:new("S", 0, {}, {}, {}, {})
}

local lookup = {
	C = tiles[1],
	L = tiles[2],
	S = tiles[3]
} 

local input = {
    {'L','L','L','L'},
    {'L','L','L','L'},
    {'L','L','L','L'},
    {'L','C','C','L'},
    {'C','S','S','C'},
    {'S','S','S','S'},
    {'S','S','S','S'},
}

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

for i = 1, #tiles do
	print(tiles[i].weight)
	
	
end






--Remove stack from wavetile

local w, h = 16, 16
local wave = WaveTile:start(w, h, tiles)

wave:step(1, 1)

local colors = {
	["L"] = {0.40, 0.20, 0, 1},
	["S"] = {0.50, 0.70, 0.87, 1},
	["C"] = {0.99, 0.89, 0.55, 1},
}

love.graphics.setBackgroundColor(0.7, 0.7, 0)
function love.draw()
	for y = 1, h do
		for x = 1, w do
			for i, v in ipairs(wave.map[y][x]) do
				love.graphics.setColor(colors[v.name])
			
			
				love.graphics.rectangle("fill", (x-1)*32, (y-1)*32 + (i-1)*(32/#wave.map[y][x]), 32, 32/#wave.map[y][x])
			end
		end
	end
	
	for i, v in ipairs(wave.stack) do
		love.graphics.setColor(1, 0, 0, 1)
	
		love.graphics.rectangle("line", (v[1]-1)*32, (v[2]-1)*32, 32, 32)
	end
	
	
end

function love.keypressed(key)
	if key == "return" then
		wave = WaveTile:start(w, h, tiles)
		wave:step(math.random(1, w), math.random(1, h))
	else
		wave:step()
	end
end