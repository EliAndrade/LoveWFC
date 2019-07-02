local Tile = require "Tile"

local GR = {}

local dirs = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}, {-1, 1}, {-1, -1}, {1, 1}, {1, -1}}
local dirsnames = {"d", "u", "r", "l", "ru", "rd", "lu", "ld"} --Is flipped on purpose

--TODO Add wrap mode, add simmetry
function GR.fromTable(input)
	local tiles = {}
	local lookup = {}

	--/Get all tiles types
	for y = 1, #input do
		for x = 1, #input[y] do
			if not lookup[input[y][x]] then
				lookup[input[y][x]] = Tile:new(input[y][x], 0, {}, {}, {}, {})
				table.insert(tiles, lookup[input[y][x]])
			end
		end
	end
	

	GR.getRules(input, tiles, lookup)
	return tiles
end

--/Receives ImageData
function GR.fromPixels(imagedata)
	local tiles = {}
	local lookup = {}
	local colors = {}
	local input = {}

	--/Get all tiles types and create a tilemap from image
	for y = 0, imagedata:getHeight()-1 do
		table.insert(input, {})
		for x = 0, imagedata:getWidth()-1 do
			local r, g, b = imagedata:getPixel(x, y)
			
			local name = r + g^2 + b^3 --FIXME Add proper hash
			
			table.insert(input[y+1], name)
			if not lookup[name] then
				lookup[name] = Tile:new(name, 0, dirsnames)
				table.insert(tiles, lookup[name])
				colors[name] = {r, g, b}
			end
		end
	end
	
	GR.getRules(input, tiles, lookup)
	return tiles, colors
end

function GR.getRules(input, tiles, lookup)
	--/Get rules
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
end
return GR