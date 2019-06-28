local Tile = {}
Tile.name = ""
Tile.rules = {
	left = {},
	right = {},
	up = {},
	down = {}
}
Tile.weight = 1


function Tile:new(name, weight, left, right, up, down)
	local o = {}
	o.name = name
	o.weight = weight
	o.rules = {
		left = left,
		right = right,
		up = up,
		down = down
	}
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