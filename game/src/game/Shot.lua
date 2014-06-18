-----------------------------------------------------------------------------------------
--
-- Author: Gop
-- (bisous à) 2014 Tabemasu Games (www.tabemasu.com)
--
-- Shot.lua
--
-- PewPewPew
--
-----------------------------------------------------------------------------------------

local Class = {}

local utils = require("lib.ecusson.Utils")
local vec2 = require("lib.ecusson.math.vec2")
local Sprite = require("lib.ecusson.Sprite")
local aabb = require("lib.ecusson.math.aabb")
-----------------------------------------------------------------------------------------
-- Local configuration
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------
function Class.create(options)
	local self = utils.extend(Class)
	self.id = utils.getUuid()
	-- Initialize attributes
	self.sprite = Sprite.create {
		spriteSet = "generated",
		animation = "laser",
		group = groups.weapons,
		position = options.position,		
		rotation = 90
	}

	self.velocity = options.velocity
	self.position = options.position
	self.ennemy = options.ennemy
	return self
end

function Class:destroy()
	self.sprite:destroy()
	utils.deleteObject(self)
end
-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------
-- Update Loop
function Class:enterFrame(options)
	self.position = self.position + self.velocity * options.dt
	self.sprite:setPosition(self.position)
end

-- Gets the Pew AABB
function Class:getAabb(options)
	return aabb(
		vec2(self.sprite.position.x - (self.sprite.width / 2), self.sprite.position.y - (self.sprite.height / 2)),
		vec2(self.sprite.position.x + (self.sprite.width / 2), self.sprite.position.y + (self.sprite.height / 2))
	)
end
-----------------------------------------------------------------------------------------
return Class