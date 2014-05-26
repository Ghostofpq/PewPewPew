-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- Dog.lua
--
-- A cute dog
--
-----------------------------------------------------------------------------------------

local Class = {}

local utils = require("lib.ecusson.Utils")
local vec2 = require("lib.ecusson.math.vec2")
local Sprite = require("lib.ecusson.Sprite")
local Sound = require("lib.ecusson.Sound")

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

local transitionDuration = 1.0

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the environment
function Class.create(options)
	local self = utils.extend(Class)

	-- Initialize attributes
	self.spawnPoint = options.spawnPoint
	self.spawnPoint.animal = self
	self.phase = "alive"
	self.time = 0.0
	self.alive = true

	self.sprite = Sprite.create {
		spriteSet = "dog",
		animation = "idle",
		group = groups.animals,
		position = self.spawnPoint.from,
		rotation = self.spawnPoint.rotation
	}

	Sound.create("dog_spawn")

	self.sprite:addEventListener("touch", self)
	self.sprite:addEventListener("ecussonSprite", self)
	Runtime:addEventListener("ecussonEnterFrame", self)

	return self
end

-- Destroy the level
function Class:destroy()
	self.spawnPoint.animal = nil

	Runtime:removeEventListener("ecussonEnterFrame", self)
	self.sprite:removeEventListener("ecussonSprite", self)
	self.sprite:removeEventListener("touch", self)

	self.sprite:destroy()

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

	self.sprite:setPosition(utils.interpolateLinear{
		from = self.spawnPoint.from,
		to = self.spawnPoint.to,
		delta = math.min(self.time / transitionDuration, 1.0)
	})
end

function Class:touch(event)
	if self.phase == "alive" then
		self.phase = "dying"

		self.sprite:play("dead")

		Sound.create("dog_death")

		Runtime:dispatchEvent{
			name = "increaseScore",
			value = 10
		}
	end
end

-- Sprite event handler
function Class:ecussonSprite(event)
	-- Destroy object if the dying animation has ended
	if event.phase == "ended" then
		self:destroy()
	end
end

-----------------------------------------------------------------------------------------

return Class
