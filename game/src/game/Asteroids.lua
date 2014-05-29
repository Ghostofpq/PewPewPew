-----------------------------------------------------------------------------------------
--
-- Author: Gop
-- (bisous à) 2014 Tabemasu Games (www.tabemasu.com)
--
-- Asteroids.lua
--
-- A shitty piece of space rock
--
-----------------------------------------------------------------------------------------

local Class = {}

local utils = require("lib.ecusson.Utils")
local vec2 = require("lib.ecusson.math.vec2")
local Sprite = require("lib.ecusson.Sprite")
local Sound = require("lib.ecusson.Sound")
local Shot = require("src.game.Shot")
local aabb = require("lib.ecusson.math.aabb")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function Class.create(options)
	local self = utils.extend(Class)
	self.id = utils.getUuid()
	self.sprite = Sprite.create {
		spriteSet = "main",
		animation = "vaisseau",
		group = groups.playership,
		position = options.position
	}

	self.position = self.sprite.position
	self.velocity = options.velocity

	return self
end

function Class:destroy()
	self.sprite:destroy()
	utils.deleteObject(self)
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------
-- Gets the Asteroid AABB
function Class:getAabb(options)
	return aabb(
		vec2(self.sprite.position.x - (self.sprite.width / 2), self.sprite.position.y - (self.sprite.height / 2)),
		vec2(self.sprite.position.x + (self.sprite.width / 2), self.sprite.position.y + (self.sprite.height / 2))   
	)
end
-- Update Loop
function Class:enterFrame(options)
	self.position = self.position + self.velocity * options.dt
	self.sprite:setPosition(self.position)
end
-----------------------------------------------------------------------------------------

return Class