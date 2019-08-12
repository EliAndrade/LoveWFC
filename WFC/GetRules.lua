local Tile = require "WFC.Tile"

local GR = {}

local dirsnames = {"u", "ru", "r", "rd", "d", "ld", "l", "lu"}
local directions = {
	{x =  0, y =  1, name = "u" },
	{x = -1, y =  1, name = "ru"},
	{x = -1, y =  0, name = "r" },
	{x = -1, y = -1, name = "rd"},
	{x =  0, y = -1, name = "d" },
	{x =  1, y = -1, name = "ld"},
	{x =  1, y =  0, name = "l" },
	{x =  1, y =  1, name = "lu"},
}


local function hashFromColor(r, g, b, a)
	return r + g*256 + b*(256^2) + a*(256^3)
end


--/Receives Table
function GR.fromTable(input, wrap)
	local tiles = {}
	local lookup = {}

	--/Get all tiles types
	for y = 1, #input do
		for x = 1, #input[y] do
			if not lookup[input[y][x]] then
				lookup[input[y][x]] = Tile:new(input[y][x], 0, dirsnames)
				table.insert(tiles, lookup[input[y][x]])
			end
		end
	end
	

	GR.getRules(input, tiles, lookup, wrap)
	return tiles
end


--/Receives ImageData
function GR.fromPixels(imagedata, wrap)
	local tiles = {}
	local lookup = {}
	local colors = {}
	local input = {}

	--/Get all tiles types and create a tilemap from image
	for y = 0, imagedata:getHeight()-1 do
		table.insert(input, {})
		for x = 0, imagedata:getWidth()-1 do
			local r, g, b, a = imagedata:getPixel(x, y)
			
			local name = tostring(hashFromColor(r, g, b, a))
			
			table.insert(input[y+1], name)
			if not lookup[name] then
				lookup[name] = Tile:new(name, 0, dirsnames)
				table.insert(tiles, lookup[name])
				colors[name] = {r, g, b, a}
			end
		end
	end
	
	GR.getRules(input, tiles, lookup, wrap)
	return tiles, colors
end


--/Get rules based on a input table received
function GR.getRules(input, tiles, lookup, wrap)
	for y = 1, #input do
		for x = 1, #input[y] do
			lookup[input[y][x]].weight = lookup[input[y][x]].weight + 1
			for i = 1, #directions do
				local posx, posy = directions[i].x + x, directions[i].y + y
				
				if wrap then
					posx = posx <= 0 and #input[1]+posx or (posx > #input[1] and posx-#input[1] or posx)
					posy = posy <= 0 and #input   +posy or (posy > #input    and posy-#input    or posy)
				end
			
			
				if  posx >= 1 and posx <= #input[y]
				and posy >= 1 and posy <= #input then
					
					local this = lookup[input[y][x]]
					local other = lookup[input[posy][posx]]
					local found = false
					
					for j, k in ipairs(this.rules[directions[i].name]) do
						if k == other.name then
							found = true
							break
						end
					end
					
					if not found then
						table.insert(this.rules[directions[i].name], other.name)
					end
				end
			end
		end
	end
end
return GR