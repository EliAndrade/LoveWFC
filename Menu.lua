local Menu = {}
Menu.cellTable = {}
Menu.selectedX = 1
Menu.selectedY = 1
Menu.width = 100
Menu.height = 100
Menu.cellHeight = 25
Menu.cellWidth = 100
Menu.dynamicCellHeight = false

Menu.limitLines = false
Menu.linesDrawnLimit = 3

function Menu:new(table, width, height, cellWidth, cellHeight, linesLimit)
	local o = {}
	setmetatable(o, {__index = self})
	o.cellTable = table
	o.width = width
	o.height = height
	
	
	if linesLimit then
		o.limitLines = true
		o.linesDrawnLimit = linesLimit
		o.cellWidth = cellWidth or width
		o.cellHeight = cellHeight or math.floor(height/linesLimit)
	else
		o.limitLines = false
		o.cellWidth = cellWidth or width
		o.cellHeight = cellHeight or math.floor(height/#table)
	end
	
	return o
end

function Menu:draw()
	local font = love.graphics.getFont()
	
	local min, max
	
	local lenTable = #self.cellTable
	
	if self.limitLines then	
		min = math.min(lenTable-self.linesDrawnLimit+1, self.selectedX)
		max = lenTable
	else
		min = 1
		max = lenTable
	end
	
	for i = min, max do
		local v = self.cellTable[i]
		
		local j = i-min+1
		
		if i == self.selectedX then
			love.graphics.setColor(1, 1, 1, 0.3)
			love.graphics.rectangle("fill", 0, self.cellHeight*(j-1), self.cellWidth, self.cellHeight)
		end	
		
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf(v.text, 0, math.floor(self.cellHeight*(j-1)+self.cellHeight/2-font:getHeight()/2), self.cellWidth, "center")
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function Menu:keypressed(key)
	if key == "down" then
		self.selectedX = self.selectedX + 1
		if self.selectedX > #self.cellTable then
			self.selectedX = 1
		end
	elseif key == "up" then
		self.selectedX = self.selectedX - 1
		if self.selectedX < 1 then
			self.selectedX = #self.cellTable
		end
	elseif key == "return" then
		if self.cellTable[self.selectedX].onPress then
			self.cellTable[self.selectedX]:onPress()
		end
	elseif key == "left" then
		if self.cellTable[self.selectedX].onLeftPress then	
			self.cellTable[self.selectedX]:onLeftPress()
		end
	elseif key == "right" then
		if self.cellTable[self.selectedX].onRightPress then
			self.cellTable[self.selectedX]:onRightPress()
		end
	end
end


return Menu