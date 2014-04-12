-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- Spawner.lua
--
-- Show the creatures so they can be destroyed
--
-----------------------------------------------------------------------------------------

local Class = {}

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

local random = math.random

local utils = require("lib.ecusson.utils")
local vec2 = require("lib.ecusson.math.vec2")
local Dog = require("src.game.Dog")

local spawnPeriod = 1.0

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the spawner
--
-- Parameters:
--  player: The player instance
--  stage: The stage to be played on
function Class.create(options)
	local self = utils.extend(Class)

	-- Initialize attributes
	self.time = 0
	self.spawnPoints = {
		{
			from = vec2(15, 80),
			to = vec2(25, 40),
			rotation = 15
		}, {
			from = vec2(50, 140),
			to = vec2(65, 94),
			rotation = 20
		}, {
			from = vec2(120, 120),
			to = vec2(120, 80),
			rotation = 0
		}, {
			from = vec2(215, 110),
			to = vec2(205, 70),
			rotation = -10
		}, {
			from = vec2(240, 140),
			to = vec2(260, 95),
			rotation = 30
		}
	}

	Runtime:addEventListener("ecussonEnterFrame", self)

	return self
end

-- Destroy the level
function Class:destroy()
	Runtime:removeEventListener("ecussonEnterFrame", self)

	for _, spawnPoint in pairs(self.spawnPoints) do
		if spawnPoint.animal then
			spawnPoint.animal:destroy()
		end
	end

	utils.deleteObject(self)
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Enter frame handler
function Class:ecussonEnterFrame(options)
	self.time = self.time + options.dt

	if self.time >= spawnPeriod then
		self.time = self.time - spawnPeriod

		local spawnPoint
		local i = 0

		repeat
			spawnPoint = self.spawnPoints[random(#self.spawnPoints)]
			i = i + 1
		until not spawnPoint.animal or i == 10

		if not spawnPoint.animal then
			Dog.create{
				spawnPoint = spawnPoint
			}
		end
	end
end

-----------------------------------------------------------------------------------------

return Class
