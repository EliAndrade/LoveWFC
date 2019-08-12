local WaveTile = {}
WaveTile = {}
WaveTile.map = {}
WaveTile.stack = {}
WaveTile.horizontalWrap = false
WaveTile.verticalWrap = false

WaveTile.directions = {
	{x =  0, y = -1, name = "u" },
	{x =  1, y = -1, name = "ru"},
	{x =  1, y =  0, name = "r" },
	{x =  1, y =  1, name = "rd"},
	{x =  0, y =  1, name = "d" },
	{x = -1, y =  1, name = "ld"},
	{x = -1, y =  0, name = "l" },
	{x = -1, y = -1, name = "lu"},
}



function WaveTile:start(w, h, tiles, wrapH, wrapV)
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
	
	o.horizontalWrap = wrapH
	o.verticalWrap = wrapV
	
	
	o.stack = {}
	o.__index = self
	
	
	
	setmetatable(o, o)
	return o
end

function WaveTile:getPos(x, y)


	return self.horizontalWrap and ((x-1) % #self.map)+1 or x,
		   self.verticalWrap and ((y-1) % #self.map[1])+1 or y
end

function WaveTile:pushDiscoveryStack(x, y)
	for i, v in ipairs(self.stack) do
		if v[1] == x and v[2] == y then
			return 
		end
	end
	
	table.insert(self.stack, {x, y})
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
        logsum = logsum + v.weight * math.log(v.weight)
	end	

	return math.log(sum) - (logsum / sum)
end

function WaveTile:propagate(x, y)
	--Full propagation
	
	local x, y = self:getPos(x, y)
	local stack = {{x, y}}
	
	while #stack > 0 do
		local pos = table.remove(stack, 1)
		
		for i = #self.stack, 1 do
			if self:isCollapsed(pos[1], pos[2]) then
				table.remove(self.stack, i)
				--break
			end
		end
		
		
		for i, v in ipairs(self.directions) do
			local dx, dy = self:getPos(pos[1] + v.x, pos[2] + v.y)

			if not self:isCollapsed(dx, dy) and self:isValidPos(dx, dy) then
				local tiles = self.map[pos[2]][pos[1]]
				if self:constrain(tiles, v.name, dx, dy) then
					table.insert(stack, {dx, dy})
				end
			end
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

function WaveTile:constrain(tiles, dir, x, y)
	local constrained = false

	for i = #self.map[y][x], 1, -1 do
		local contain = false
		
		
		for j = 1, #tiles do
			if self.map[y][x][i]:checkIfRuleExists(tiles[j].name, dir) then
				contain = true
			end
		end
		
		if not contain then
			constrained = true
			table.remove(self.map[y][x], i)
		end
	end
	
	return constrained
end

function WaveTile:step(x, y)
	if x and y then
		self:collapse(x, y)
		for i, v in ipairs(self.directions) do
			local dx, dy = self:getPos(x + v.x, y + v.y)
		
		
			if self:isValidPos(dx, dy) then
				--table.insert(self.stack, {dx, dy})
				self:pushDiscoveryStack(dx, dy)
			end
		end
		
		return true
	else
		local minEntropy = math.huge
		local posStack = 0
		
		
	
		for i, v in ipairs(self.stack) do
			local entropy = self:getEntropy(v[1], v[2]) - love.math.random()/1000
			
			if minEntropy > entropy then
				minEntropy = entropy
				posStack = i
			end
		end
		
		if posStack ~= 0 then
			local x, y = self.stack[posStack][1], self.stack[posStack][2]
			table.remove(self.stack, posStack)
		
			
			for i, v in ipairs(self.directions) do
				local dx, dy = self:getPos(x + v.x, y + v.y)
			
				if self:isValidPos(dx, dy) and not self:isCollapsed(dx, dy) then
					self:pushDiscoveryStack(dx, dy)
				end
			end
			
			self:collapse(x, y)
			
			return true
		end
	end
	
	return false
end


return WaveTile