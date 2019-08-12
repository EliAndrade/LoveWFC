local Tile = {}
Tile.name = ""
Tile.rules = {}
Tile.weight = 1


function Tile:new(name, weight, dirs)
	local o = {}
	o.name = name
	o.weight = weight
	o.rules = {}
	
	for i, v in ipairs(dirs) do
		o.rules[v] = {}
	end
	o.__index = self
	
	setmetatable(o, o)
	
	return o
end

function Tile:checkIfRuleExists(tilename, dir)
	for i, v in ipairs(self.rules[dir]) do
		if v == tilename then
			return true
		end
	end
	
	return false
end

return Tile