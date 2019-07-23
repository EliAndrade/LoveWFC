local FPS_LIMIT = false
local GRAPHICAL_FPS = 1/144
local love = love

function love.run()
	if love.load then love.load(love.filesystem.isFused()) end
	
	--We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
	local dtSinceFrame = 0
	local drawsSkipped = 0
 
	--Main loop time.
	return function()
		--Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 		
		--Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end
 
		--Call update and draw
		if love.update then love.update(dt) end --will pass 0 if love.timer is disabled
 		dtSinceFrame = dtSinceFrame + dt
 		
 		
 		
		if love.graphics and love.graphics.isActive() and dtSinceFrame >= GRAPHICAL_FPS then
			while dtSinceFrame >= GRAPHICAL_FPS do
				dtSinceFrame = dtSinceFrame - GRAPHICAL_FPS
			end
			
		
		
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
 
			if love.draw then love.draw(drawsSkipped) end
 
			love.graphics.present()
			
			drawsSkipped = 0
		end
		
		drawsSkipped = drawsSkipped + 1
 
		if love.timer and FPS_LIMIT then
			love.timer.sleep(0.001) 
		end
	end
end