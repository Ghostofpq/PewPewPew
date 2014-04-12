-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- TimelinePlayer.lua
--
-- A timeline player.
--
-----------------------------------------------------------------------------------------

local utils = require("lib.ecusson.Utils")

-----------------------------------------------------------------------------------------

local Class = {}

-----------------------------------------------------------------------------------------
-- Local attributes
-----------------------------------------------------------------------------------------

local max = math.max

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the timeline player
--
-- Parameters:
--  timeline: The timeline
--  target: The target object containing methods to be called
--  delay: The delay before playing the timeline (optional)
--  loop: If true, the timeline loops (optional, default is false)
--  duration: The loop duration (optional, default is the maximum value of at, from and to values)
--  start: To start the timeline at a certain point
function Class.create(options)
	local self = utils.extend(Class)

	-- Initialize attributes
	self.timeline = options.timeline
	self.target = options.target
	self.delay = options.delay or 0
	self.loop = options.loop or false
	self.duration = options.duration
	self.playing = false
	self.previousTime = 0
	self.time = options.start or 0
	self.finishing = false

	if not self.duration then
		self.duration = 0

		for i = 1, #self.timeline do
			local fx = self.timeline[i]
			self.duration = max(self.duration, fx.from or 0, fx.to or 0, fx.at or 0)
		end
	end
	
	self:resetFXs()

	return self
end

-- Called immediately after scene has moved onscreen:
function Class:destroy(event)
	utils.deleteObject(self)
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Checks if the timeline is playing
function Class:isPlaying()
	return self.playing
end

-- Stop the player
function Class:play()
	self.playing = true
	self:update()
end

-- Restart the timeline
function Class:restart()
	self.time = 0
	self:resetFXs()
	self:play()
end

-- Stop the player
function Class:stop()
	self.playing = false
	self.time = 0
	self:update()
end

-- Stop the player
function Class:pause()
	self.playing = false
end

-- Stop the player
function Class:resume()
	self.playing = true
end

-- Reset the FX flags
function Class:resetFXs()
	-- Reset fxs
	for _, fx in pairs(self.timeline) do
		fx.started = false
		fx.finished = false
	end
end

-- Advance in the timeline
--
-- Parameters:
--  time: The time to add to the timeline
function Class:forward(time)
	self.time = self.time + time
	self:update()
end

-- Finish the timeline immediately
function Class:finish()
	self.finishing = true
	if self.time < self.duration then
		self:forward(self.duration - self.time)
	end
end

-- Check is the timeline is finished
--
-- Returns true if the timeline is finished
function Class:isFinished()
	return self.duration and self.time >= self.duration
end

-- Update the scene
function Class:update()
	for i = 1, #self.timeline do
		local fx = self.timeline[i]
		local start = fx.from ~= nil and fx.from or fx.at

		if self.time >= start then
			-- Time is between "from" and "to"
			if fx.from ~= nil and (fx.to == nil or self.time <= fx.to) then
				local options = {
					parameters = fx.parameters,
					firstFrame = not fx.started,
					delta = self.time - fx.from,
					finishing = self.finishing
				}

				-- Compute progress
				if fx.to then
					options.duration = fx.to - fx.from
					options.progress = options.delta / options.duration

					if options.progress == 1 then
						fx.finished = true
					end
				end

				-- Send event
				if not self.target[fx.action] then
					utils.softError("Timeline error: action "..fx.action.." does not exist in target.")
				else
					self.target[fx.action](self.target, options)
				end

			-- Time is after "to" or "at" and FX has not been played yet
			elseif not fx.finished then
				fx.finished = true

				-- Send event
				if not self.target[fx.action] then
					utils.softError("Timeline error: action "..fx.action.." does not exist in target.")
				else
					if fx.at ~= nil then
						self.target[fx.action](self.target, {
							parameters = fx.parameters,
							firstFrame = true,
							delta = 0.0,
							duration = 0.0,
							progress = 1.0,
							finishing = self.finishing
						})
					else
						self.target[fx.action](self.target, {
							parameters = fx.parameters,
							firstFrame = not fx.started,
							delta = fx.to - fx.from,
							duration = fx.to - fx.from,
							progress = 1.0,
							finishing = self.finishing
						})
					end
				end
			end

			fx.started = true
		end
	end
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Enter frame handler
function Class:enterFrame(options)
	if self.playing then
		if self.delay > 0 then
			self.delay = self.delay - options.dt
		else
			self.previousTime = self.time
			self.time = self.time + options.dt

			self:update()

			-- Check if it needs to loop
			if self.loop and self.time >= self.duration then
				self:restart()
			end
		end
	end
end

-----------------------------------------------------------------------------------------

return Class
