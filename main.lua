require "run"

--FIXME Add more directions

love.graphics.setDefaultFilter("nearest", "nearest")

local Tile = require "Tile"
local WaveTile = require "WaveTile"

local dirs = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}
local dirsnames = {"up", "down", "left", "right"}

local Menu = require "Menu"

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

local GetRules = require "GetRules"

local pixel = love.graphics.newImage("pixel.png")
local TILE_SIZE = 4

local imagedata = love.image.newImageData("image8.png")
local image = love.graphics.newImage(imagedata)

local tiles, colors = GetRules.fromPixels(imagedata)
local w, h = 100, 100
local wave = WaveTile:start(w, h, tiles, true, true)

love.window.updateMode(800, h*TILE_SIZE, {vsync = false})


--/Menu
local t = {}
local function less(self)
	self.tile.weight = self.tile.weight > 0 and self.tile.weight - 1 or 0
	self.text = ("%s: %i"):format(
		type(self.tile.name) == "number" and
				("%.2f"):format(self.tile.name)
			or
				self.tile.name, self.tile.weight)	
end
local function more(self)
	self.tile.weight = self.tile.weight + 1
	self.text = ("%s: %i"):format(
		type(self.tile.name) == "number" and
				("%.2f"):format(self.tile.name)
			or
				self.tile.name, self.tile.weight)	
end

for i, v in ipairs(tiles) do
	table.insert(t, {
		text = ("%s: %i"):format(
			type(v.name) == "number" and
				("%.2f"):format(v.name)
			or
				v.name,
		v.weight),
	
		onLeftPress = less,
		onRightPress = more,
		tile = v
	})
end


local weightmenu = Menu:new(t, 100, #t*16)


local step = 0
love.graphics.setBackgroundColor(0.7, 0.7, 0)
function love.draw(jumpedUpdates)
	local lg = love.graphics

	for y = 1, h do
		for x = 1, w do
			for i, v in ipairs(wave.map[y][x]) do	
				if wave:isCollapsed(x, y) then
					lg.setColor(colors[v.name][1], colors[v.name][2], colors[v.name][3], 1-wave:getEntropy(x, y))
				
				
					lg.rectangle("fill", (x-1)*TILE_SIZE, (y-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
				end
				--lg.draw(pixel, (x-1)*TILE_SIZE, (y-1)*TILE_SIZE, 0, TILE_SIZE, TILE_SIZE)
			end
		end
	end
	
	for i, v in ipairs(wave.stack) do
		--lg.setColor(1, 0, 0, 1)
	
		--lg.rectangle("line", (v[1]-1)*TILE_SIZE, (v[2]-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
	end
	
	
	lg.setColor(1, 1, 1, 1)
	lg.print(step)
	lg.print(#wave.stack, 0, 16)
	lg.print(jumpedUpdates, 0, 32)
	
	lg.push()
	lg.translate(w*TILE_SIZE, 0)
	weightmenu:draw()
	
	lg.translate(0, #tiles*16)
	lg.print("Input:", 16, 0)
	
	lg.setColor(0, 0, 0, 1)
	lg.rectangle("line", 16, 16, image:getWidth()*TILE_SIZE, image:getHeight()*TILE_SIZE)
	lg.setColor(1, 1, 1, 1)
	
	lg.draw(image, 16, 16, 0, TILE_SIZE, TILE_SIZE)
	
	lg.pop()
end


function love.update(dt)
	for i = 1, 10 do
		if wave:step() then
			step = step + 1
		end
	end
end

function love.keypressed(key)
	if key == "return" then
		wave = WaveTile:start(w, h, tiles, true, true)
		wave:step(math.random(1, w), math.random(1, h))
		step = 0
	elseif key == "a" then
		for i = 1, 1000 do
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