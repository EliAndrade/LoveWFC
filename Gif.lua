local Gif = {}
Gif.quads = {}
Gif.mixshader = love.graphics.newShader("AnimMix.glsl")
Gif.image = nil
Gif.quads = {}
Gif.timer = 0
Gif.maxtime = 1/60
Gif.__index = nil
Gif.onFrame = 1
Gif.amountOfFrames = 0
Gif.smoothTransition = true
	

function Gif:new(image, width, height, fps)
	local o = {}
	
	o.image = image
	o.quads = {}
	o.timer = 0
	o.maxtime = 1/fps
	o.__index = self
	o.onFrame = 1
	o.amountOfFrames = 0
	
	local imgw, imgh = image:getDimensions()
	for y = 0, imgh/height-1 do
		for x = 0, imgw/width-1 do
			o.amountOfFrames = o.amountOfFrames + 1
			table.insert(o.quads, love.graphics.newQuad(x*width, y*height, width, height, imgw, imgh))
		end
	end
	
	
	setmetatable(o, o)
	
	return o
end

function Gif:update(dt)
	self.timer = self.timer + dt
	if self.timer >= self.maxtime then
		self.timer = self.timer - self.maxtime
		self.onFrame = self.onFrame + 1
		if self.onFrame > self.amountOfFrames then
			self.onFrame = 1
		end
	end
end

function Gif:draw(x, y)
	love.graphics.push("all")
	love.graphics.draw(self.image, self.quads[self.onFrame], x, y)
	love.graphics.pop()
end

function Gif:release()
	self.quads = nil
	self.image:release()
end

return Gif








