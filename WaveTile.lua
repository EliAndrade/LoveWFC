local WaveTile = {}
WaveTile = {}
WaveTile.map = {}
WaveTile.dirs = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}
WaveTile.dirsnames = {"up", "down", "left", "right"}
WaveTile.stack = {}

function WaveTile:start(w, h, tiles)
	local o = {}
	o.map = {}
	
	for y = 1, h do
		table.insert(o.map, {})
		for x = 1, w do
			table.insert(o.map[y], {})		
			for i, v in ipairs(tiles) do
				table.insert(o.map[y][x], v)
			end
		end
	end
	
	o.stack = {}
	o.__index = self
	
	setmetatable(o, o)
	return o
end

function WaveTile:isValidPos(x, y)
	return 
		x >= 1 and
		x <= #self.map[1] and
		y >= 1 and
		y <= #self.map
end

function WaveTile:collapse(x, y)
	local sum = 0
	
	for i, v in ipairs(self.map[y][x]) do
        sum = sum + v.weight
	end
	
	local r = love.math.random(1, sum)
	
	local selected = 0
	for i, v in ipairs(self.map[y][x]) do
		r = r - v.weight
		
		
		if r <= 0 then
			selected = i
			break
		end
	end
	
	self.map[y][x] = {self.map[y][x][selected]}
	
	for i = 1, #self.stack do
		if x == self.stack[i][1] and y == self.stack[i][2] then
			table.remove(self.stack, i)
			break
		end
	end
	
	self:propagate(x, y)
end

function WaveTile:getEntropy(x, y)
	local sum = 0
    local logsum = 0
    
    for i, v in ipairs(self.map[y][x]) do
        sum = sum + v.weight
        logsum = sum + v.weight * math.log(v.weight)
	end

	return math.log(sum) - (logsum / sum)
end

function WaveTile:propagate(x, y)
	for i, v in ipairs(self.dirs) do
		if not self:isCollapsed(x + v[1], y + v[2]) and self:isValidPos(x + v[1], y + v[2]) then
			self:constrain(self.map[y][x][1], self.dirsnames[i], x + v[1], y + v[2])
		end
	end
end

function WaveTile:isCollapsed(x, y)
	if self:isValidPos(x, y) then
		return #self.map[y][x] == 1
	else
		return true
	end
end

function WaveTile:isAllCollapsed()
	for y = 1, #self.map do
		for x = 1, #self.map[y] do
			if #self.map[y][x] > 1 then
				return false
			end
		end
	end
	
	return true
end

function WaveTile:constrain(tile, dir, x, y)

	for i = #self.map[y][x], 1, -1 do
		if not self.map[y][x][i]:checkIfRuleExists(tile.name, dir) then
			table.remove(self.map[y][x], i)
		end
	end
end

function WaveTile:step(x, y)
	if x and y then
		self:collapse(x, y)
		for i, v in ipairs(self.dirs) do
			if self:isValidPos(x + v[1], y + v[2]) then
				table.insert(self.stack, {x + v[1], y + v[2]})
			end
		end
		
		
	else
		local minEntropy = math.huge
		local posStack = 0
		
		
	
		for i, v in ipairs(self.stack) do
			local entropy = self:getEntropy(v[1], v[2])
			
			if minEntropy > entropy then
				minEntropy = entropy
				posStack = i
			end
		end

		
		if posStack ~= 0 then
			local x, y = self.stack[posStack][1], self.stack[posStack][2]
			table.remove(self.stack, posStack)
		
			
			for i, v in ipairs(self.dirs) do
				if self:isValidPos(x + v[1], y + v[2]) and not self:isCollapsed(x + v[1], y + v[2]) then
					table.insert(self.stack, {x + v[1], y + v[2]})
				end
			end
			
			self:collapse(x, y)
		end
	end
end


return WaveTile